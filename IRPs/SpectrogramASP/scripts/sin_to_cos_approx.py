import math

import numpy as np
import pandas as pd

import plotly.express as px


### Error of sin(-w) ~= 1 - cos(w) ###
freq_start = 1
freq_step = 1
freq_stop = 5e3  # (freq_stop - freq_start) must be a multiple of freq_step*N
sample_freq = 24e3  # 0.5 * 48 kHz

freqs = np.arange(freq_start, freq_stop, freq_step)

cos_actual = np.zeros(freqs.size)
cos_estimate = np.zeros(freqs.size)

for (idx, freq) in enumerate(freqs):
    cos_actual[idx] = math.cos(-2 * np.pi * (freq / sample_freq))
    cos_estimate[idx] = 1 - math.sin(2 * np.pi * (freq / sample_freq))

    freq += freq_step

sin_cos_err = cos_estimate - cos_actual
sin_cos_df = pd.DataFrame(
    {
        "f": freqs,
        "actual": cos_actual,
        "estimate": cos_estimate,
        "error": sin_cos_err,
        "error_norm": 100 * sin_cos_err / cos_actual,
    }
)
sin_cos_fig = px.line(
    sin_cos_df,
    x="f",
    y=["actual", "estimate", "error", "error_norm"],
    title="Error of cos(-w) ~= 1 - sin(-w)",
)
sin_cos_fig.show()

# SHOUD NOT USE
# Passes 5% error ~ 200 Hz
# Reaches 85% error ~ 4500 Hz

## Plot for specific freq and compare ##
freq_idx = 3500
x = np.arange(512 * 2)
y_cos = np.cos(2 * np.pi * (freqs[freq_idx] / sample_freq) * x)

# Estimate
sin_w = math.sin(2 * np.pi * (freqs[freq_idx] / sample_freq))  # cos(w)

y_cos_est = np.zeros(x.shape)
y_cos_est[0] = 1  # sin(w*0)
y_cos_est[-1] = cos_estimate[freq_idx]
# y_cos_est[-1] = math.cos(-2 * np.pi * (freqs[freq_idx] / sample_freq))  # -sin(w)

for (idx, y) in enumerate(y_cos_est[1:]):
    idx = idx + 1  # offset since first element already assigned
    y_cos_est[idx] = 2 * sin_w * y_cos_est[idx - 1] - y_cos_est[idx - 2]

err = y_cos_est - y_cos

plot_df = pd.DataFrame(
    {
        "x": x,
        "actual": y_cos,
        "estimate": y_cos_est,
        "error": err,
        "error_norm": 100 * err / y_cos,
    }
)
plot_fig = px.line(
    plot_df,
    x="x",
    y=["actual", "estimate", "error", "error_norm"],
    title=f"Error of {freqs[freq_idx]} Hz cos seeded with  1 - sin(w)",
)
plot_fig.show()

print("Z-TRANFORM FOR COSINE IS INCORRECT, MUST READ UP ON IT!")
raise Exception
