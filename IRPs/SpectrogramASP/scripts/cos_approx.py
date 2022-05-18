import math

import numpy as np
import pandas as pd

import plotly.express as px

### Cosine Sequential Approximation ###

# https://dspguru.com/dsp/tricks/sine_tone_generator/
# https://azrael.digipen.edu/MAT321/DiscreteTimeSignalProcessing3.pdf
# y[n] = 2*cos(w)*y[n-1] - y[n-2]
# from the derivation we would expect to sum 1 + {-cos(w) n=1, 0 else}
# but this is not so... don't understand the why not

# Parameters
samples = 512
f_sample = 48e3

f_0 = f_sample / samples  # fundamental frequency, window = 1 period
k = 255  # k <= samples/2 for Nyqist upper measurable bound
f_tone = f_0 * k


# Ideal
x = np.arange(samples)  # SAMPLES (not time!)
y_cos = np.cos(2 * np.pi * (f_tone / f_sample) * x)

# Estimate
cos_w = math.cos(2 * np.pi * (f_tone / f_sample))  # cos(w)

y_cos_est = np.zeros(x.shape)
y_cos_est[0] = 1  # cos(0)
# y_cos_est[-1] = math.cos(2 * np.pi * (f_tone / f_sample))  # cos(-w)
# Re-using previously calculated cos_w...
y_cos_est[-1] = cos_w  # cos-(w) = cos(w)

for (idx, y) in enumerate(y_cos_est[1:]):
    idx = idx + 1  # offset since first element already assigned
    y_cos_est[idx] = 2 * cos_w * y_cos_est[idx - 1] - y_cos_est[idx - 2]

# Plot
y_cos_err = y_cos_est - y_cos
y_cos_err_proportional = 100 * y_cos_err / y_cos
cos_fig = pd.DataFrame(
    {
        "x": x,
        "actual": y_cos,
        "estimate": y_cos_est,
        "error": y_cos_err,
        "error_proportional": y_cos_err_proportional,
    }
)
sin_fig = px.line(
    cos_fig,
    x="x",
    y=["actual", "estimate", "error", "error_proportional"],
    title="cos plot",
)
sin_fig.show()

print("Error:")
print(pd.DataFrame(y_cos_err).describe())
print()
print("f_sample = " + str(f_sample))
print("samples = " + str(samples))
print("f_0 = " + str(f_0))
print("k = " + str(k))
print("---")
print("f_tone = " + str(f_tone))
print("w = " + str(2 * np.pi * (f_tone / f_sample)))
print("cos(w) = " + str(cos_w))
