import numpy as np
import pandas as pd
import plotly.express as px

import util.approximate_sinusoid as u_as
import util.approximate_sinusoid_int as u_asi

# Floating Point Error (Proof of Accuracy)
# k: int = 30
# (df, x, ys) = u_as.approximate_sinusoid(512, 48e3 / 2, k)
# fig = px.line(df, x, ys, title="Sin/Cos Estimate")
# fig.show()

# Integer Representation Error (Implementation)
k: int = 20
bits: int = 16
(df, x, ys, _) = u_asi.approximate_sinusoid_int(
    512, 48e3 / 2, k, bits, debug=True, normalise_estimate=True
)
fig = px.line(df, x, ys, title="Int Sin/Cos Estimate")
fig.show()


"""
Compare accuracy of iterative z-transform sinusoid estimation
for a spread of k (frequencies equal to k/samples) and different
bit precision.
"""
# Plot maximum error across int size and value of k
# (for fixed number of samples)
samples = 512
sample_frequency = 48e3 / 2
ks = np.arange(1, samples // 2)
bits = np.arange(8, 16 + 1)  # 16 inclusive

max_error = np.zeros((ks.shape[0], bits.shape[0]))

for (idx_k, k) in enumerate(ks):
    for (idx_b, b) in enumerate(bits):
        (df, _, _, _) = u_asi.approximate_sinusoid_int(
            samples, sample_frequency, k, b, normalise_estimate=True
        )
        max_error[idx_k][idx_b] = max(abs(df["y_cos_error"]))

# Linear
fig_hm = px.imshow(
    max_error,
    aspect="auto",
    title="Maximum Error in Sinusoid Estimation (for kth harmonic, integer bits)",
    labels=dict(x="N bits", y="kth harmonic"),
    x=bits,  # label
    y=ks,  # label
)
fig_hm.show()

# Clipped
max_error_clip = max_error.clip(0, 0.15)  # clip to 15% error

fig_hm_clip = px.imshow(
    max_error_clip,
    aspect="auto",
    title="Maximum Error (clamped to 15%) in Sinusoid Estimation (for kth harmonic, integer bits)",
    labels=dict(x="N bits", y="kth harmonic"),
    x=bits,  # label
    y=ks,  # label
)
fig_hm_clip.show()


# Find trend in error over iterations
b = 16
df_err_trend = pd.DataFrame()
for k in ks:
    (df, _, _, _) = u_asi.approximate_sinusoid_int(
        samples, sample_frequency, k, b, normalise_estimate=True
    )
    norm_err = abs(df["y_cos_error"]) / max(df["y_cos_error"])
    df_err_trend[k] = norm_err

df_err_trend = df_err_trend.copy()  # defrag
fig_err_trend = px.scatter(
    df_err_trend,
    title="Error Trend Over Iterations (for kth harmonics)",
    labels=dict(x="sample", y="normalised error"),
)
fig_err_trend.show()
