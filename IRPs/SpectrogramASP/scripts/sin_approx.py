import math

import numpy as np
import pandas as pd

import plotly.express as px

### Sine Sequential Approximation ###

# https://dspguru.com/dsp/tricks/sine_tone_generator/
# y[n] = 2*cos(w)*y[n-1] - y[n-2]

# Parameters
samples = 512
f_sample = 48e3

f_0 = f_sample / samples  # fundamental frequency, window = 1 period
k = 64  # k <= samples/2 for Nyqist upper measurable bound
f_tone = f_0 * k

# Ideal
x = np.arange(samples)  # SAMPLES (not time!)
y_sin = np.sin(2 * np.pi * (f_tone / f_sample) * x)


# Estimate
cos_w = math.cos(2 * np.pi * (f_tone / f_sample))  # cos(w)
n_sin_w = -math.sin(2 * np.pi * (f_tone / f_sample))  # -sin(w)

y_sin_est = np.zeros(x.shape)
y_sin_est[0] = 0  # sin(w*0)
y_sin_est[-1] = n_sin_w

for (idx, y) in enumerate(y_sin_est[1:]):
    idx = idx + 1  # offset since first element already assigned
    y_sin_est[idx] = 2 * cos_w * y_sin_est[idx - 1] - y_sin_est[idx - 2]

# Plot
y_sin_err = y_sin_est - y_sin
y_sin_err_norm = 100 * (y_sin_err / y_sin)
sin_df = pd.DataFrame(
    {
        "x": x,
        "actual": y_sin,
        "estimate": y_sin_est,
        "error": y_sin_err,
        "error_norm": y_sin_err_norm,
    }
)
sin_fig = px.line(
    sin_df, x="x", y=["actual", "estimate", "error", "error_norm"], title="sin plot"
)
sin_fig.show()

print("Error:")
print(pd.DataFrame(y_sin_err).describe())
print()
print("f_sample = " + str(f_sample))
print("samples = " + str(samples))
print("f_0 = " + str(f_0))
print("k = " + str(k))
print("---")
print("f_tone = " + str(f_tone))
print("w = " + str(2 * np.pi * (f_tone / f_sample)))
print("cos(w) = " + str(cos_w))
print("-sin(w) = " + str(n_sin_w))
