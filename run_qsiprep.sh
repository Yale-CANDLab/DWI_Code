#! /bin/bash
#SBATCH --job-name=qsiprep_gpu_shapes
#SBATCH --ntasks=1 --nodes=1
#SBATCH --mem-per-cpu=40G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-gpu=1
#SBATCH --gpus=1
#SBATCH --mail-user=lucinda.sisk@yale.edu
#SBATCH --partition=psych_gpu

ml purge
sub=$1

#DSI Studio installed locally within QSIprep dir
#MRTrix installed locally

subjdir='/gpfs/milgram/scratch60/gee_dylan/lms233/QSIPrep/bids_data'
datadir='/gpfs/milgram/project/gee_dylan/candlab/analyses/shapes/dwi/QSIPrep'
home='/gpfs/milgram/pi/gee_dylan/candlab/analyses/shapes/dwi/QSIPrep'
scripts='/gpfs/milgram/pi/gee_dylan/lms233/QSIprep'

outdir=${datadir}/output_data
workdir=${subjdir}/../working_dir

cd /gpfs/milgram/pi/gee_dylan/lms233/QSIprep

singularity run --nv -B ${subjdir},${outdir} qsiprep-0.14.3.sif ${subjdir} ${outdir} participant --skip_bids_validation --participant_label ${sub} --prefer-dedicated-fmaps --output_resolution=1 --fs-license-file='/home/lms233/license.txt' --work-dir=${workdir} --unringing-method='mrdegibbs' --eddy-config=${scripts}/eddy_params_lms.json --impute-slice-threshold=3  --write-graph --b0-to-t1w-transform='Affine' --nthreads 8 #--omp-nthreads 1
