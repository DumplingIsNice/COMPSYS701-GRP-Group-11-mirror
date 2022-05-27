import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

import util.spectrogram


"""Parameters"""
samples = 512
sample_frequency = 48e3 / 2

x = np.arange(samples)
ks = np.arange(0, (samples // 2) + 1)

"""Test Signal (int16)"""
f100 = np.sin(2 * np.pi * (100 / sample_frequency) * x)
# near minimum Nyquist measurable
f10k = np.sin(2 * np.pi * (10e3 / sample_frequency) * x)
# near maximum Nyquist measurable
f250 = np.sin(2 * np.pi * (250 / sample_frequency) * x)
# lower band of most speech frequencies
f5k = np.sin(2 * np.pi * (5e3 / sample_frequency) * x)
# upper band of most speech frequencies

f4k2 = np.sin(2 * np.pi * (4.2e3 / sample_frequency) * x)
# arbitrary test signal

# int16 range is 32767 to -32768
test_signal = np.zeros(x.shape)
test_signal += f100 * 1000
test_signal += f250 * 16000
test_signal += f4k2 * 16333
test_signal += f5k * 32000
test_signal += f10k * 2000


"""Plot DFT"""
(dft_re, dft_im, dft_magnitude, k_frequencies) = util.spectrogram.dft(
    test_signal, sample_frequency
)

df = pd.DataFrame(
    {
        "fk": k_frequencies,
        "dft_re": dft_re,
        "dft_im": dft_im,
        "dft_magnitude": dft_magnitude,
    }
)
# fig = px.line(df, x="fk", y="dft_magnitude")
# fig.show()

# Subplot DFT (for report)
subplot = make_subplots(rows=2, cols=1)
subplot.add_trace(
    go.Scatter(name="Signal", x=k_frequencies, y=test_signal), row=1, col=1
)
# subplot.add_trace(
#     go.Scatter(name="DFT", x=k_frequencies, y=dft_re), row=2, col=1
# )
subplot.add_trace(
    go.Scatter(name="DFT", x=k_frequencies, y=dft_magnitude), row=2, col=1
)
subplot.update_layout(
    title="DFT", xaxis_title="Frequency (Hz)", yaxis_title="Magnitude (linear)"
)
subplot.show()


"""Plot DFT int16"""
(dft_re, dft_im, dft_magnitude, k_frequencies) = util.spectrogram.dft_int16(
    test_signal, sample_frequency
)

df = pd.DataFrame(
    {
        "fk": k_frequencies,
        "dft_re": dft_re,
        "dft_im": dft_im,
        "dft_magnitude": dft_magnitude,
    }
)
# Subplot DFT (for report)
subplot = make_subplots(rows=2, cols=1)
subplot.add_trace(
    go.Scatter(name="Signal", x=k_frequencies, y=test_signal), row=1, col=1
)
# subplot.add_trace(
#     go.Scatter(name="DFT", x=k_frequencies, y=dft_re), row=2, col=1
# )
subplot.add_trace(
    go.Scatter(name="DFT", x=k_frequencies, y=dft_magnitude), row=2, col=1
)
subplot.update_layout(
    title="DFT int16", xaxis_title="Frequency (Hz)", yaxis_title="Magnitude (linear)"
)
subplot.show()


"""np.fft.fft()"""
if False:
    np_fft = np.fft.fft(test_signal, ks.shape[0])
    df_np_fft = pd.DataFrame(
        {
            "fk": k_frequencies,
            "np_fft_magnitude": abs(np_fft),
        }
    )
    fig_np_fft = px.line(df_np_fft, x="fk", y="np_fft_magnitude")
    fig_np_fft.show()
