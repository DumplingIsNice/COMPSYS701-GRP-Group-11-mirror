import math

import numpy as np
import pandas as pd

import plotly.express as px

# As w changes the value of cos(w), sin(w) that intersects
# the end of the window changes, traversing the sinusoid.
# Thus we cannot take advantage of sin(wn) ~= 1 - cos(wn)
# at the very start of the period since we may sample at any
# point throughout the period.

# f_tone = f_0*k / f_sample
samples = 512
f_sample = 48e3 / 2
f_0 = f_sample / samples  # fundamental frequency, window = 1 period
k = np.arange(1, samples / 2)

frequencies = (f_0 * k) / f_sample

y_sin = np.sin(2 * np.pi * frequencies)
y_cos = np.cos(2 * np.pi * frequencies)
y_sin_est = 0

diff = y_sin - y_cos

df = pd.DataFrame(
    {
        "frequencies": frequencies,
        "sin(w)": y_sin,
        "cos(w)": y_cos,
        "diff": diff,
        "sin(w) est": y_sin_est,
    }
)
fig = px.line(
    df,
    x="frequencies",
    y=["sin(w)", "cos(w)", "diff", "sin(w) est"],
    title="cos(w) and sin(w) correlation plot",
)
fig.show()
