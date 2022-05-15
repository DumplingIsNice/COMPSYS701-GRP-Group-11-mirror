import math
from re import T
import numpy as np
import pandas as pd
import plotly.express as px

f = 1  # Hz

# x = np.arange(0, 4 * np.pi, 0.01)
x = np.arange(0, 20, 0.01)  # non-multiple of 2*pi
ysin = np.sin(2 * np.pi * f * x)
ycos = np.cos(2 * np.pi * f * x)

# plot_df = pd.DataFrame({"x": x, "sin_value": ysin, "cos_value": ycos})
# fig = px.line(plot_df, x="x", y=["sin_value", "cos_value"], title="sin plot")
# fig.show()

## ##
# https://dspguru.com/dsp/tricks/sine_tone_generator/
# y[n] = 2*cos(w)*y[n-1] - y[n-2]
#
# Sin-wave generation
# Solving y[-1] on the assumption that x is a multiple of 2*pi
# y[0] AND y[-1] CANNOT both be zero, otherwise we cannot calculate.

f_tone = f  # k
f_sample = 4  # N
cos_w = math.cos(2 * np.pi * (f_tone / f_sample))
print(cos_w)

y_sin_est = np.zeros(x.shape)
y_sin_est[1] = 0  # sin(w*0)
y_sin_est[-1] = 0  # -sin(w*0) # assuming f_tone/f_sample not fractional!
y_sin_est[-1] = -math.sin(2 * np.pi * (f_tone / f_sample))

for (idx, y) in enumerate(y_sin_est[2:]):
    y_sin_est[idx] = 2 * cos_w * y_sin_est[idx - 1] - y_sin_est[idx - 2]


y_sin_err = ysin - y_sin_est
sin_df = pd.DataFrame(
    {"x": x, "actual": ysin, "estimate": y_sin_est, "error": y_sin_err}
)
sin_fig = px.line(sin_df, x="x", y=["actual", "estimate", "error"], title="sin plot")
sin_fig.show()
