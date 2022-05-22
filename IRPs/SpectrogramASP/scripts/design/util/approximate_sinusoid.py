import math
import numpy as np
import pandas as pd


def approximate_sinusoid(
    samples: int, sample_frequency: int, k: int
) -> tuple[pd.DataFrame, str, list[str]]:
    """
    Use Z-transform to estimate sine and cosine in terms of discrete time.
    Return the ideal, estimatations, and error. Calculated at full precision.

    Parameters
    ----------
    samples: int
        Must be log2
    sample_frequency: int
        Must be an even value greater than 0.
    k: int
        Tone frequency is f_0*k, where f0 has a period equal to the window length
        (i.e., frequency of sample_frequency/samples).

    Returns
    -------
    df
        Dataframe of ideal sin and cos, estimated sin and cos, and errors
        for a sinusoid with frequency f_0*k.
    x_name: str
        Name of index column.
    y_names: list[str]
        List of data names.

    """
    # Parameter Parsing
    assert math.log2(samples) % 1 == 0
    assert sample_frequency % 2 == 0
    assert sample_frequency > 0
    assert k >= 0 and k <= samples // 2

    #
    f_0: float = sample_frequency / samples  # fundamental frequency, window = 1 period
    f_tone: float = f_0 * k
    # frequency: float = f_tone / sample_frequency
    # where f_tone/sample_frequency = f_0*k/sample_frequency = k/samples, thus:
    frequency: float = k / samples

    print(f"samples={samples}, sample_frequency={sample_frequency}, k={k}")
    print(f"f_0={f_0}, f_tone={f_tone}, f_tone/f_sample={frequency}")

    x = np.arange(samples)  # samples/index, not time!

    # Ideal
    y_cos = np.cos(2 * np.pi * frequency * x)
    y_sin = np.sin(2 * np.pi * frequency * x)

    # Estimate
    y_cos_est = np.zeros(x.shape)
    y_sin_est = np.zeros(x.shape)

    cos_w = math.cos(2 * np.pi * frequency)

    y_cos_est[0] = 1
    y_cos_est[-1] = cos_w  # cos(-w) = cos(w)

    y_sin_est[0] = 0
    y_sin_est[-1] = -math.sin(2 * np.pi * frequency)  # sin(-w) = -sin(w)

    for (idx, _) in enumerate(y_cos_est[1:]):
        # y[n] = 2*cos(w)*y[n-1] - y[n-2]
        idx = idx + 1  # offset since first value already assigned
        y_cos_est[idx] = 2 * cos_w * y_cos_est[idx - 1] - y_cos_est[idx - 2]
        y_sin_est[idx] = 2 * cos_w * y_sin_est[idx - 1] - y_sin_est[idx - 2]

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
