"""
Created on Thu Oct 14 14:59:55 2021

@author: Artin Isagholian
"""


from scipy import signal
import numpy as np



def int16_to_hex(num):
    if num < 0:
        return hex((1 << 16) + num)
    else:
        return hex(num)
    
def float_to_fixed(num, fractional_bits):
    x = num * 2**fractional_bits;
    return np.short(round(x))
    

#fir filter coeff creation
num_taps = 60;
filter_cutoff = 1e6;
sampling_freq = 40e6;
nyquist_freq = sampling_freq/2;
coeff_list = signal.firwin(numtaps=num_taps, cutoff=filter_cutoff, window='blackman', pass_zero=True, fs=sampling_freq)


#generate fixed point coeffs
fixed_point_coeff = [];
for coeff in coeff_list:
    fixed_point_coeff.append(int16_to_hex(float_to_fixed(coeff,15)))
    
#make mem file
coeff_mem_file = open("FIR_LPF_COEFF.mem","w+")
for i in range(len(fixed_point_coeff)):
    coeff_mem_file.write(str(fixed_point_coeff[i]).replace("0x","").upper().zfill(4) + "\n")
coeff_mem_file.close()



