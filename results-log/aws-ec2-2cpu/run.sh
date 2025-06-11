docker run --cpus=$1 --rm -v $(pwd)/results:/benchmark/results 484907510442.dkr.ecr.us-east-1.amazonaws.com/language-benchmark /benchmark/scripts/run_all_benchmarks.sh $2
