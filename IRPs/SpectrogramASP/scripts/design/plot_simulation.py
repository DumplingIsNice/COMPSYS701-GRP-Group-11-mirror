import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# load script generated reference Signal
test_signal = np.loadtxt("generated/int16_signal.txt", dtype=int)
# load simulation output (from modelsim)
magnitudes = np.loadtxt("generated/simulation/test_log.txt", dtype=int)
# load script generated frequencies for each value of k
frequencies = np.loadtxt("generated/LUT_frequencies.txt", dtype=int)


# Subplot DFT (for report)
subplot = make_subplots(rows=2, cols=1)
subplot.add_trace(go.Scatter(name="Signal", x=frequencies, y=test_signal), row=1, col=1)
subplot.add_trace(go.Scatter(name="DFT", x=frequencies, y=magnitudes), row=2, col=1)
subplot.update_layout(
    title="DFT", xaxis_title="Frequency (Hz)", yaxis_title="Magnitude (linear)"
)
subplot.show()
