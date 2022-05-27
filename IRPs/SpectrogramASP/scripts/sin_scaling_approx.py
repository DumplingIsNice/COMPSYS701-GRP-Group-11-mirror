import math

import numpy as np
import pandas as pd

import plotly.express as px

### Error for Sin Seed Approximation ###
freq_start = 1
freq_step = 1
freq_stop = 5e3  # (freq_stop - freq_start) must be a multiple of freq_step*N
sample_freq = 24e3  # 0.5 * 48 kHz

freqs = np.arange(freq_start, freq_stop, freq_step)


sin_actual = np.zeros(freqs.size)
sin_estimate = np.zeros(freqs.size)

sin_actual[0] = -math.sin(2 * np.pi * (freq_start / sample_freq))
sin_estimate[0] = -math.sin(2 * np.pi * (freq_start / sample_freq))

for (idx, freq) in enumerate(freqs[1:]):
    idx += 1  # adjust for starting offset

    # Calculate ideal sin(-w) value
    sin_actual[idx] = -math.sin(2 * np.pi * (freq / sample_freq))
    # Calculate extrapolated sin(-w) by multipling by change in freq <--!
    sin_estimate[idx] = sin_estimate[idx - 1] * ((freq + freq_step) / freq)

    freq += freq_step

err = sin_estimate - sin_actual
estimate_error_df = pd.DataFrame(
    {
        "f": freqs,
        "actual": sin_actual,
        "estimate": sin_estimate,
        "error": err,
        "error_norm": 100 * err / sin_actual,
    }
)
estimate_error_fig = px.line(
    estimate_error_df,
    x="f",
    y=["actual", "estimate", "error", "error_norm"],
    title="Error of Estimating sin(-w) From Initial Value",
)
estimate_error_fig.show()

# Error surpasses 5% after ~385 iterations, peaks at around 35% after
# 4000 iterations. Not practical to extrapolate heavily.

## Plot for specific freq and compare
freq_idx = 222
x = np.arange(512 * 2)
y_sin = np.sin(2 * np.pi * (freqs[freq_idx] / sample_freq) * x)

# Estimate
cos_w = math.cos(2 * np.pi * (freqs[freq_idx] / sample_freq))  # cos(w)

y_sin_est = np.zeros(x.shape)
y_sin_est[0] = 0  # sin(w*0)
y_sin_est[-1] = -math.sin(2 * np.pi * (freqs[freq_idx] / sample_freq))  # -sin(w)

for (idx, y) in enumerate(y_sin_est[1:]):
    idx = idx + 1  # offset since first element already assigned
    y_sin_est[idx] = 2 * cos_w * y_sin_est[idx - 1] - y_sin_est[idx - 2]

err = y_sin_est - y_sin

plot_df = pd.DataFrame(
    {
        "x": x,
        "actual": y_sin,
        "estimate": y_sin_est,
        "error": err,
        "error_norm": 100 * err / y_sin,
    }
)
plot_fig = px.line(
    plot_df,
    x="x",
    y=["actual", "estimate", "error", "error_norm"],
    title=f"Error of {freqs[freq_idx]} Hz sinusoid seeded with estimate",
)
plot_fig.show()