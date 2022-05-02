# IRP
- Hardware acceleration of digital signal processing algorithms.
- Application Specific Processors (ASP) in Heterogeneous Multiprocessor System-on-Chip (HMPSoC). Configured to perform processing in any combination of a pipeline of ASP.
- The HMPSoC's application is signal processing. This ASP proposed implements ... function.
- Analogue-to-Digital Converters (ADC) with  associated ADC-ASP, Digital-to-Analogue Converter (DAC) with associated DAC-AS
## Report Format
0) Background
1) Literature Review
	1) Function (kernels) in
		1) Digital Design processing
		2) Artificial Neural Networks
		3) Identify those of interest
2) Function Selection wrt. GRP
3) ASP architecture/Implementation
	1) Including interface with TDMA-MIN
	2) Including message protocol
	3) Including the system process in how the function is invoked

## Definition
- Command Responses Chart
- Format of message package exchanged + Protocol
- Architecture
	- All data storage elements (internal memory)
	- Interface to NoC
	- Display Datapath + Control Unit
- Analysis of performance & trade-off
	- Time to perform vs resource usage
- Explore panellisation options

- 6 to 8-page single column report (10 pt. font, Times New Roman) that includes the  descriptions of findings on related topics in the literature, short presentation/definition of implemented algorithms, diagrams of overall DP-ASP structure and its datapath, summary of capabilities and the ways of using the DP-ASP, and references.  
- The design of the DP-ASP; individual designs will be used by the design team to integrate into HMPSoC. The design has to be tested with realistic external requirements implemented within the testbed (in ModelSim) and synthesised into an **IP block** that can be instantiated in HMPSoC in any number of instances in DE1-SoC (or DE2-115).

## Data Processing Function Kernels
- **Direct passthrough**, taking input data samples and immediately outputting them to a specified destination over NoC  
- **Linear Filter** - moving average filter on any array A or B (where X is A or B), storage of the resulting array back to  the original location or delivering it to another ASP. Moving window size is programmable and can be L= 4 or L=8. For the boundaries of array, a solution has to be defined.  
- $$Y(i) = \frac{\sum X(k)}{L},k=i,i+1,...,i+L-1$$
- **Finite Impulse Response filter** of Nth order with fixed coefficients  
- **Correlation function** (between two different time series stored in two arrays or over the same time series – autocorrelation)  
- **Peak detection** where the ASP records data to the internal memory and outputs the current maximum and minimum values for the specified/sampling period  
- **Averaging** – where the ASP computes a rolling average over the specified/sampling period  
- **Frequency detection** of the incoming data received via NoC  
- **Accelerating machine learning (ML) computations** such as computations in convolutional layers of a Convolutional Neural Networks (CNN)