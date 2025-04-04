# This file is used for anisotropy analysis by Neper. 
# Pole figure and inverse pole figure are plotted.
# NOTE1: The .tesr file was named as map1.tesr, map2.tesr etc.
# NOTE2: A filter is applied here: anisotropy factor larger than 1.8.


#!/bin/bash

# Define output files
output_file="combined_stcell_data_1_th18"
axes_ref_file="axes_ref_1_th18"
axes_crys_file="axes_crys_1_th18"

# Clear output files if they exist
> "$output_file"
> "$axes_ref_file"
> "$axes_crys_file"

# Loop through all .tesr files from map1-1 to map1-104
for i in $(seq 1 1); do
    # Generate the file names
    tesr_file="map${i}.tesr"
    stcell_file="map${i}.stcell"

    # Run Neper command for the current file
    echo "Processing $tesr_file ..."
    neper -T -loadtesr "$tesr_file" -statcell oridisanisoangles,oridisanisoaxes,oridisanisofact,oridisanisoaxes_crys

    # Check if the .stcell file was created
    if [ -f "$stcell_file" ]; then
        echo "Adding $stcell_file to $output_file..."
        
        # Append the content of the .stcell file to the combined text file
        echo "==== File: $stcell_file ====" >> "$output_file"
        cat "$stcell_file" >> "$output_file"
        echo "" >> "$output_file"  # Add a newline for separation

        # Extract first principal axis (reference and crystal coordinate system) ONLY if column $13 > 1.6
        awk '$13+0 > 1.8 {print $4, $5, $6}' "$stcell_file" >> "$axes_ref_file"
        awk '$13+0 > 1.8 {print $14, $15, $16}' "$stcell_file" >> "$axes_crys_file"

    else
        echo "Warning: $stcell_file not found!"
    fi
done

         
neper -V "v1(type=vector):file(axes_ref_1_th18)"   \
         -datav1col blue                    \
         -space pf                          \
         -pfmode density                    \
         -pfprojection equal-area             \
         -datav1colscheme viridis:fade      \
         -datav1scale 0:5                   \
         -print axes_ref_density_1_th18   

neper -V "v1(type=vector):file(axes_ref_1_th18)"   \
         -datav1col blue                    \
         -space pf                          \
         -pfmode density,symbol             \
         -pfprojection equal-area             \
         -datav1colscheme viridis:fade      \
         -datav1scale 0:5                   \
         -print axes_ref_density_1_sym_th18    

neper -V "v1(type=vector):file(axes_crys_1_th18)"  \
         -datav1col blue                    \
         -space ipf                         \
         -ipfmode density            \
         -ipfprojection equal-area             \
         -datav1colscheme viridis:fade      \
         -datav1scale 0:5                   \
         -print axes_crys_density_1_th18
         
neper -V "v1(type=vector):file(axes_crys_1_th18)"  \
         -datav1col blue                    \
         -space ipf                         \
         -ipfmode density,symbol            \
         -ipfprojection equal-area             \
         -datav1colscheme viridis:fade      \
         -datav1scale 0:5                   \
         -print axes_crys_density_1_sym_th18
echo "All .stcell files have been processed and combined into $output_file!"
echo "Filtered first principal axes (reference) saved in $axes_ref_file!"
echo "Filtered first principal axes (crystal) saved in $axes_crys_file!"
