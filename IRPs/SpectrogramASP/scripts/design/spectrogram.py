import math
import numpy as np
import pandas as pd

import util.approximate_sinusoid_int as u_asi


def dft_int16(signal, sample_frequency: int):
    """
    Calculate DFT by summing the correlation of the signal for each
    kth reference signal. Uses integer approximation of sine/cosine
    k signals, and max-min magnitude approximation.

    Does NOT correct for the 2^15 scaling. TODO: >> 16 before magnitude?

    Parameters
    ----------
    signal
        int16 signal to perform DFT on.
        The length of the signal is the number of samples.
        Must have a length of log2
    sample_frequency: int
        Hz at which the signal was sampled.

    Returns
    -------
    dft_re
        Cos components
    dft_im
        Sin components
    dft_magnitude
        Correlation magnitude, i.e. |cos_k + j*sin_k|
    k_frequencies
        k frequencies in terms of Hz. No integer rounding applied, these values are
        for plotting/comparison.
    """

    """Parameters"""
    bits = 16

    samples = len(signal)
    assert math.log2(samples) % 1 == 0, "signal length must be log2"

    x = np.arange(samples)
    ks = np.arange(0, (samples // 2) + 1)

    """DFT"""
    dft_re = np.zeros(ks.shape, dtype=int)
    dft_im = np.zeros(ks.shape, dtype=int)

    signal = np.array(signal).astype(int)

    for (idx, k) in enumerate(ks):
        (df, _, _) = u_asi.approximate_sinusoid_int(samples, sample_frequency, k, bits)
        ref_cos = np.array(df["y_cos_est"]).astype(int)
        ref_sin = np.array(df["y_sin_est"]).astype(int)

        for (n, _) in enumerate(signal):
            dft_re[idx] += np.right_shift(ref_cos[n] * signal[n], bits)
            dft_im[idx] += np.right_shift(ref_sin[n] * signal[n], bits)
            # remove offset here to prevent sum() overflow,
            # and in hardware try maintain word length of 16
            # NOTE: sum() is effectively int16*15, which needs 9 extra bits (int25)

        # dft_re[idx] = sum(np.right_shift(ref_cos * signal, bits))
        # dft_im[idx] = sum(np.right_shift(ref_sin * signal, bits))

        # take average of sum to get output in terms/scale of input signal
        dft_re[idx] = np.right_shift(dft_re[idx], int(math.log2(samples)))
        dft_im[idx] = np.right_shift(dft_im[idx], int(math.log2(samples)))

    dft_magnitude = np.zeros(ks.shape)
    for (idx, _) in enumerate(ks):
        dft_magnitude[idx] = approx_magnitude_int(dft_re[idx], dft_im[idx])

    k_frequencies = (ks / samples) * sample_frequency

    return (dft_re, dft_im, dft_magnitude, k_frequencies)


def approx_magnitude_int(a: int, b: int) -> int:

    # https://www.embedded.com/digital-signal-processing-tricks-high-speed-vector-magnitude-approximation/
    # https://dspguru.com/dsp/tricks/magnitude-estimator/
    # |a+jb| ~= alpha*max(|a|,|b|) + beta*min(|a|,|b|)
    # common coefficients are (1, 0.5) w/ avg linear error of -8.68%
    a = abs(a)
    b = abs(b)
    out: int = int(max(a, b)) + (int(min(a, b)) >> 1)
    return int(out)


def dft(signal, sample_frequency: int):
    """
    Calculate DFT by summing the correlation of the signal for each
    kth reference signal.

    NOTE:
    Divides sum by number of samples to get average to keep values sane,
    scale consistent.

    Parameters
    ----------
    signal
        Signal to perform DFT on.
        The length of the signal is the number of samples.
    sample_frequency: int
        Hz at which the signal was sampled.

    Returns
    -------
    dft_re
        Cos components
    dft_im
        Sin components
    dft_magnitude
        Correlation magnitude, i.e. |cos_k + j*sin_k|
    k_frequencies
        k frequencies in terms of Hz
    """

    """Parameters"""
    samples = len(signal)
    x = np.arange(samples)
    ks = np.arange(0, (samples // 2) + 1)

    """DFT"""
    dft_re = np.zeros(ks.shape)
    dft_im = np.zeros(ks.shape)

    for (idx, k) in enumerate(ks):
        ref_cos = np.cos(2 * np.pi * (k / samples) * x)
        ref_sin = np.sin(2 * np.pi * (k / samples) * x)

        dft_re[idx] = sum(ref_cos * signal) / samples
        dft_im[idx] = sum(ref_sin * signal) / samples

    dft_magnitude = np.sqrt(pow(dft_re, 2) + pow(dft_im, 2))
    k_frequencies = (ks / samples) * sample_frequency

    return (dft_re, dft_im, dft_magnitude, k_frequencies)
