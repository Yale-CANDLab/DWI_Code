#! /bin/bash

#SBATCH --job-name=TractSeg
#SBATCH --ntasks=1 --nodes=1
#SBATCH --mem-per-cpu=20G
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=lucinda.sisk@yale.edu
#SBATCH --partition=psych_day

ml load miniconda
conda activate shapes-dwi3.7

sub=$1

home='/gpfs/milgram/pi/gee_dylan/candlab/analyses/shapes/dwi/QSIPrep'
recondir='/gpfs/milgram/pi/gee_dylan/candlab/analyses/shapes/dwi/QSIPrep/output_data/qsirecon'
outpath=${home}/output_data/tractseg_output/${sub}

mkdir ${home}/output_data/tractseg_output
mkdir ${home}/output_data/tractseg_output/${sub}

#Register FA image to MNI template
flirt -in ${recondir}'/'${sub}'/ses-shapesV1/dwi/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-fa0_gqiscalar.nii.gz' -ref '/gpfs/milgram/pi/gee_dylan/candlab/atlases/MNI152_T1_2mm_brain.nii.gz' -out ${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-fa0_gqiscalar_MNIreg.nii.gz' -omat ${outpath}'/'${sub}'_FAtoMNI_Transform.mat'

#Convert MIF data to Nii.Gz
mrconvert -force ${recondir}'/'${sub}'/ses-shapesV1/dwi/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd.mif.gz' ${recondir}'/'${sub}'/ses-shapesV1/dwi/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd.nii.gz'

#Apply transform to ODF data
flirt -in ${recondir}'/'${sub}'/ses-shapesV1/dwi/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd.nii.gz' -ref '/gpfs/milgram/pi/gee_dylan/candlab/atlases/MNI152_T1_2mm_brain.nii.gz' -out ${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd_MNIreg.nii.gz' -init ${outpath}'/'${sub}'_FAtoMNI_Transform.mat' -applyxfm

#Convert Nii.Gz data to MIF
mrconvert -force ${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd_MNIreg.nii.gz' ${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd_MNIreg.mif.gz'

#Convert normalized MSMT FODs to Peaks

sh2peaks -force ${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd_MNIreg.mif.gz' ${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd_Peaks_MNIreg.mif.gz'

mrconvert -force ${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd_Peaks_MNIreg.mif.gz' ${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd_Peaks_MNIreg.nii.gz'

# # Run Tract Seg
peaksfile=${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-wmFODmtnormed_msmtcsd_Peaks_MNIreg.nii.gz'
gqifile=${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-gfa_gqiscalar_MNIreg.nii.gz'

echo 'Starting TractSeg for '${sub}

# # Run full TractSeg
/gpfs/milgram/project/gee_dylan/lms233/conda_envs/shapes-dwi3.7/bin/TractSeg -i $peaksfile -o ${outpath} --output_type endings_segmentation

/gpfs/milgram/project/gee_dylan/lms233/conda_envs/shapes-dwi3.7/bin/TractSeg -i $peaksfile -o ${outpath} --output_type tract_segmentation

/gpfs/milgram/project/gee_dylan/lms233/conda_envs/shapes-dwi3.7/bin/TractSeg -i $peaksfile -o ${outpath} --output_type TOM

/gpfs/milgram/project/gee_dylan/lms233/conda_envs/shapes-dwi3.7/bin/Tracking -i $peaksfile -o ${outpath} --nr_fibers 5000

echo 'Extracting peak length tractometry for '${sub}

/gpfs/milgram/project/gee_dylan/lms233/conda_envs/shapes-dwi3.7/bin/Tractometry -i ${outpath}/TOM_trackings -o ${outpath}/${sub}_Tractometry_PeakLength.csv -e ${outpath}/endings_segmentations/ -s $peakfile --TOM ${outpath}/TOM --peak_length

for type in fa0 fa1 fa2 gfa iso ad md rd ; do

    echo 'Extracting FA tractometry for '${sub}
    flirt -in ${recondir}'/'${sub}'/ses-shapesV1/dwi/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-'${type}'_gqiscalar.nii.gz' -ref '/gpfs/milgram/pi/gee_dylan/candlab/atlases/MNI152_T1_2mm_brain.nii.gz' -out ${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-'${type}'_gqiscalar_MNIreg.nii.gz' -init ${outpath}'/'${sub}'_FAtoMNI_Transform.mat' -applyxfm

    gqifile=${outpath}'/'${sub}'_ses-shapesV1_space-T1w_desc-preproc_space-T1w_desc-'${type}'_gqiscalar_MNIreg.nii.gz'
    /gpfs/milgram/project/gee_dylan/lms233/conda_envs/shapes-dwi3.7/bin/Tractometry -i ${outpath}/TOM_trackings -o ${outpath}/${sub}_Tractometry_${type}Metrics.csv -e ${outpath}/endings_segmentations -s $gqifile

    echo '* Done *'
done
