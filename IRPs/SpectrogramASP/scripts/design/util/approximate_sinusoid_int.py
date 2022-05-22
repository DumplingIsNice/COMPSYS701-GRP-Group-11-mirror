import math
import numpy as np
import pandas as pd


def to_fixed_point_int(x, range: int) -> int:
    """Convert a value between -1 and 1 to within <=range, >=-range bounds."""
    y: int = int(x * range)

    assert y <= range  # may fail if float precision is off!
    assert y >= -range
    return y


def approximate_sinusoid_int(
    samples: int,
    sample_frequency: int,
    k: int,
    int_fixed_point_bits: int,
    debug: bool = False,
    normalise_estimate=False,
) -> tuple[pd.DataFrame, str, list[str]]:
    """
    Use Z-transform to estimate sine and cosine in terms of discrete time.
    Return the ideal, estimatations, and error.
    Calculated with integer rounding and truncation for bitwise representation.

    Parameters
    ----------
    samples: int
        Must be log2
    sample_frequency: int
        Must be an even value greater than 0.
    k: int
        Tone frequency is f_0*k, where f0 has a period equal to the window length
        (i.e., frequency of sample_frequency/samples).
    int_fixed_point_bits: int
        Number of bits (including sign bit) available to use when estimating
        the sinusoid.

    Returns
    -------
    df
        Dataframe of ideal sin and cos, estimated sin and cos, and errors
        for a sinusoid with frequency f_0*k.
        ["y_cos",
        "y_sin",
        "y_cos_est",
        "y_sin_est",
        "y_cos_error",
        "y_sin_error",]
    x_name: str
        Name of index column.
    y_names: list[str]
        List of data names.

    """
    ## Parameter Parsing
    assert math.log2(samples) % 1 == 0
    assert sample_frequency % 2 == 0
    assert sample_frequency > 0
    assert k >= 0 and k <= samples // 2
    assert int_fixed_point_bits > 0

    SINUSOID_FXP_RANGE: int = int(
        pow(2, int_fixed_point_bits - 1) - 1
    )  # 1:range, 0:0, -1:-range

    f_0: float = sample_frequency / samples  # fundamental frequency, window = 1 period
    f_tone: float = f_0 * k
    # frequency: float = f_tone / sample_frequency
    # where f_tone/sample_frequency = f_0*k/sample_frequency = k/samples, thus:
    frequency: float = k / samples

    if debug:
        print(f"samples={samples}, sample_frequency={sample_frequency}, k={k}")
        print(f"f_0={f_0}, f_tone={f_tone}, int f_tone/f_sample={frequency}")

    ## Calculate
    x = np.arange(samples)  # samples/index, not time!

    # Ideal
    y_cos = np.cos(2 * np.pi * frequency * x)
    y_sin = np.sin(2 * np.pi * frequency * x)

    # Estimate
    y_cos_est = np.zeros(x.shape)
    y_sin_est = np.zeros(x.shape)

    cos_w = math.cos(2 * np.pi * frequency)
    sin_nw = -math.sin(2 * np.pi * frequency)  # sin(-w) = -sin(w)

    y_cos_est[0] = to_fixed_point_int(1, SINUSOID_FXP_RANGE)
    y_cos_est[-1] = to_fixed_point_int(cos_w, SINUSOID_FXP_RANGE)

    y_sin_est[0] = to_fixed_point_int(0, SINUSOID_FXP_RANGE)
    y_sin_est[-1] = to_fixed_point_int(sin_nw, SINUSOID_FXP_RANGE)

    for (idx, _) in enumerate(y_cos_est[1:]):
        # y[n] = 2*cos(w)*y[n-1] - y[n-2]
        idx = idx + 1  # offset since first value already assigned
        y_cos_est[idx] = int(int(2 * cos_w * y_cos_est[idx - 1]) - y_cos_est[idx - 2])
        y_sin_est[idx] = int(int(2 * cos_w * y_sin_est[idx - 1]) - y_sin_est[idx - 2])

    if normalise_estimate:
        # Normalise for plotting comparison
        y_cos_est = y_cos_est / SINUSOID_FXP_RANGE
        y_sin_est = y_sin_est / SINUSOID_FXP_RANGE

    y_cos_error = y_cos_est - y_cos
    y_sin_error = y_sin_est - y_sin

    df = pd.DataFrame(
        {
            "x": x,
            "y_cos": y_cos,
            "y_sin": y_sin,
            "y_cos_est": y_cos_est,
            "y_sin_est": y_sin_est,
            "y_cos_error": y_cos_error,
            "y_sin_error": y_sin_error,
        }
    )
    x_name: str = "x"
    y_names: list[str] = [
        "y_cos",
        "y_sin",
        "y_cos_est",
        "y_sin_est",
        "y_cos_error",
        "y_sin_error",
    ]

    return (df, x_name, y_names)
