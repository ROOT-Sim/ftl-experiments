for i in speed_trajectories/*.csv; do 

dest=$(python3 -c "print('$i'.replace('speed_trajectories', 'phold_trace').replace('csv','txt'))")
echo $i $dest #
python3 convert_to_lpfractions.py $i $dest 0.004 1 -100.0 95.0 0.0001 #-72.6 82.3 0.245

done
