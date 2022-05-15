import math

import numpy as np
import pandas as pd

import plotly.express as px

### Sine/Cosine Sequential Approximation ###

# https://dspguru.com/dsp/tricks/sine_tone_generator/
# y[n] = 2*cos(w)*y[n-1] - y[n-2]

# Parameters
f_tone = 5e3  # k
f_sample = 44e3  # 32 * 4  # N

# Ideal
x = np.arange(512)  # SAMPLES (not time!)
ysin = np.sin(2 * np.pi * (f_tone / f_sample) * x)

# Estimate
cos_w = math.cos(2 * np.pi * (f_tone / f_sample))  # cos(w)

y_sin_est = np.zeros(x.shape)
y_sin_est[0] = 0  # sin(w*0)
y_sin_est[-1] = -math.sin(2 * np.pi * (f_tone / f_sample))  # -sin(w)

for (idx, y) in enumerate(y_sin_est[1:]):
    idx = idx + 1  # offset since first element already assigned
    y_sin_est[idx] = 2 * cos_w * y_sin_est[idx - 1] - y_sin_est[idx - 2]

# Plot
y_sin_err = y_sin_est - ysin
sin_df = pd.DataFrame(
    {"x": x, "actual": ysin, "estimate": y_sin_est, "error": y_sin_err}
)
sin_fig = px.line(sin_df, x="x", y=["actual", "estimate", "error"], title="sin plot")
sin_fig.show()

print("Error:")
print(pd.DataFrame(y_sin_err).describe())
