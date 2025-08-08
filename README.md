# RIR_stats
Contains helper functions for analyzing room impulse response data from several microphone configurations (single, binaural, etc.)
---
### `/+samples/`

Contains sample room impulse responses and HRTF (Head-Related Transfer Function) data.

- **`h010_Livingroom_31txts.wav`**  
  RIRs recorded in a living room setting. This was taken from the MIT IR survey [ref1]

- **`h252_Auditorium_1txts.wav`**  
  RIRs recorded in an auditorium setting. This was taken from the MIT IR survey [ref1]

- **`mit_kemar_normal_pinna.sofa`**  
  MIT KEMAR dummy head HRTF dataset.

  [ref_1] : J. Traer, & J.H. McDermott, Statistics of natural reverberation enable perceptual separation of sound and space, Proc. Natl. Acad. Sci. U.S.A. 113 (48) E7856-E7865, https://doi.org/10.1073/pnas.1612524113 (2016).

---

### `/+util/`

Functions for RIR feature extraction

- **`applyHalfHann.m`**  
  Helper function for windowing RIRs, useful for removing noise which might bias results

- **`calcClarity.m`**  
  Computes clarity (c50 or any other specified time window,) representing the ratio of early to late sound energy. Used to assess speech and music intelligibility.

- **`calcDRR.m`**  
  Calculates the Direct-to-Reverberant Ratio (DRR), indicating how much direct sound energy is present compared to reverberation. (User specified direct window)

- **`calcITD_ILD_IC.m`**  
  Extracts interaural cues from binaural impulse responses:
  - **ITD**: Interaural Time Difference  
  - **ILD**: Interaural Level Difference  
  - **IC**: Interaural Coherence

- **`calcLEF.m`**  
  Computes the Lateral Energy Fraction (LEF), a spatial impression metric based on the amount of energy arriving from the sides. This requires an omnidirectional and a figure 8 measurement taken with the null of the figure 8 microphone pointing at the sound source

- **`calcRT.m`**  
  Estimates the reverberation time (T20, T30, or any other user specified decay value.) It can also calculate EDT

- **`octsmooth.m`**  
 Gets octave smoothed PSD values and the frequency vector up to nyquist + 1
---

### `testing.m`

Example script demonstrating the usage of the utility functions on the sample RIR and HRTF data.

---



---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
