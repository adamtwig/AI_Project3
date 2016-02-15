# bash script to run k-fold trials

PY_PROGRAM=src/documentClassifier.py
PY_COMMAND=kfold
PY_DATASET=data/mergedData/forum.data
BASH_KFOLD=output/kfold_stdout.txt
BASH_PERCENT=output/kfold_percents.txt
PY_AGGREGATE=src/kfold.py

# ensure that argument for number of iterations provided
# Reference:
# - http://stackoverflow.com/questions/6482377/check-existence-of-input-argument-in-a-bash-shell-script
if [ -z "$1" ]; then
    echo "Missing argument for number of iterations to run!"
    exit 1
fi

# remove old data
rm -f ${BASH_KFOLD}
rm -f ${BASH_PERCENT}

# run n k-fold cross validation trials
# always start at 2-fold
# Reference:
# - http://www.cyberciti.biz/faq/unix-linux-iterate-over-a-variable-range-of-numbers-in-bash/
# - https://momentum.spindance.com/2016/01/bash-basics-control-structures/
# - https://www.digitalocean.com/community/tutorials/using-grep-regular-expressions-to-search-for-text-patterns-in-linux#grouping
# - http://regexr.com/
START=2
END=$1
for (( n=$START; n<=$END; n++ )); do
    # execute program, saving (overwriting) output file
    python ${PY_PROGRAM} ${PY_COMMAND} ${PY_DATASET} $n > ${BASH_KFOLD}

    # search for effectiveness percentages and save to variable
    percents=$(grep -o "\(Effectiveness: \d\d%\)" ${BASH_KFOLD})

    # for each word in space separated list, iterate through
    for percent in $percents; do
        # if item is actually a percent, some are words like "effectiveness"
        if [[ $percent == [0-9][0-9]% ]] ; then
            # save off the percent to a file
            echo $percent >> ${BASH_PERCENT}
        fi
    done
done

# use python script to find the average and maximum of the percentages
python ${PY_AGGREGATE} ${BASH_PERCENT}
