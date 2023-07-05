#!/bin/bash
ns=$1
wld=$2

echo ${ns} ${wld}

## Source Provider
echo '------------------------------'
echo 'Source Provider'
echo '------------------------------'
sp=$(kubectl -n ${ns} get gitrepo ${wld} \
-o custom-columns='GitRepo NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,LAST_TRANSITION:.status.conditions[-1].lastTransitionTime')
echo "${sp}" | awk '{ printf("  %s\n", $0) }'


## Source Tester
echo '------------------------------'
echo 'Source Tester'
echo '------------------------------'
st=$(kubectl -n ${ns} get runnable ${wld} \
-o custom-columns='Runnable NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,LAST_TRANSITION:.status.conditions[-1].lastTransitionTime')
echo "${st}" | awk '{ printf("  %s\n", $0) }'
test_pipelineruns1=$(kubectl -n ${ns} get pipelineruns -l carto.run/workload-name=${wld} -l carto.run/runnable-name=${wld} -o 'jsonpath={.items[-1].metadata.name}' --sort-by='.metadata.creationTimestamp')
st_test_pipelineruns1=$(kubectl -n ${ns} get pipelineruns ${test_pipelineruns1} \
-o custom-columns='Last_PipelineRuns NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,COMPLETION_TIME:.status.completionTime')
echo "${st_test_pipelineruns1}" | awk '{ printf("    %s\n", $0) }'

## Source Scan
echo '------------------------------'
echo 'Source Scan'
echo '------------------------------'
sc=$(kubectl -n ${ns} get sourcescan ${wld} \
-o custom-columns='SourceScan NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,LAST_TRANSITION:.status.conditions[-1].lastTransitionTime')
echo "${sc}" | awk '{ printf("  %s\n", $0) }'
scan_taskruns1=$(kubectl -n ${ns} get taskruns -l carto.run/workload-name=${wld} -l app.kubernetes.io/component=source-scan -o 'jsonpath={.items[-1].metadata.name}' --sort-by='.metadata.creationTimestamp')
sc_scan_taskruns1=$(kubectl -n ${ns} get taskruns ${scan_taskruns1} \
-o custom-columns='Last_TaskRuns NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,COMPLETION_TIME:.status.completionTime')
echo "${sc_scan_taskruns1}" | awk '{ printf("    %s\n", $0) }'

## Image Build
echo '------------------------------'
echo 'Image Build'
echo '------------------------------'
ib=$(kubectl -n ${ns} get imgs ${wld} \
-o custom-columns='Images NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,LAST_TRANSITION:.status.conditions[-1].lastTransitionTime')
echo "${ib}" | awk '{ printf("  %s\n", $0) }'
builds1=$(kubectl -n ${ns} get build -l carto.run/workload-name=${wld} -o 'jsonpath={.items[-1].metadata.name}' --sort-by='.metadata.creationTimestamp')
echo "Latest Build Name" | awk '{ printf("    %s\n", $0) }'
echo "${builds1}" | awk '{ printf("    %s\n", $0) }'
build1pod=$(kubectl -n ${ns} get pod -l carto.run/workload-name=${wld} -l kpack.io/build=${builds1} \
-o custom-columns='BuildPod NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,FINISHED＿TIME:.status.containerStatuses[?(@.name=="completion")].state.terminated.finishedAt')
echo "${build1pod}" | awk '{ printf("      %s\n", $0) }'

## Image Scan
echo '------------------------------'
echo 'Image Scan'
echo '------------------------------'
is=$(kubectl -n ${ns} get imagescan ${wld} \
-o custom-columns='ImageScan NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,LAST_TRANSITION:.status.conditions[-1].lastTransitionTime')
echo "${is}" | awk '{ printf("  %s\n", $0) }'
imagescan_taskruns1=$(kubectl -n ${ns} get taskruns -l carto.run/workload-name=${wld} -l app.kubernetes.io/component=image-scan -o 'jsonpath={.items[-1].metadata.name}' --sort-by='.metadata.creationTimestamp')
is_imagescan_taskruns1=$(kubectl -n ${ns} get taskruns ${imagescan_taskruns1} \
-o custom-columns='Last_TaskRuns NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,COMPLETION_TIME:.status.completionTime')
echo "${is_imagescan_taskruns1}" | awk '{ printf("    %s\n", $0) }'

## Config Provider
echo '------------------------------'
echo 'Config Provider'
echo '------------------------------'
cp_wld_status_lastime=$(kubectl -n ${ns} get wld ${wld} \
-o custom-columns='Last_Ready_TransitionTime:.status.resources[?(@.name=="config-provider")].conditions[?(@.reason=="Ready")].lastTransitionTime')
echo "${cp_wld_status_lastime}" | awk '{ printf("  %s\n", $0) }'

## App Config
echo '------------------------------'
echo 'App Config'
echo '------------------------------'
ac_wld_status_lastime=$(kubectl -n ${ns} get wld ${wld} \
-o custom-columns='Last_Ready_TransitionTime:.status.resources[?(@.name=="app-config")].conditions[?(@.reason=="Ready")].lastTransitionTime')
echo "${ac_wld_status_lastime}" | awk '{ printf("  %s\n", $0) }'

## Servive Bindings
echo '------------------------------'
echo 'Servive Bindings'
echo '------------------------------'
sb_wld_status_lastime=$(kubectl -n ${ns} get wld ${wld} \
-o custom-columns='Last_Ready_TransitionTime:.status.resources[?(@.name=="service-bindings")].conditions[?(@.reason=="Ready")].lastTransitionTime')
echo "${sb_wld_status_lastime}" | awk '{ printf("  %s\n", $0) }'

## API descriptors
echo '------------------------------'
echo 'API Descriptors'
echo '------------------------------'
apid_wld_status_lastime=$(kubectl -n ${ns} get wld ${wld} \
-o custom-columns='Last_Ready_TransitionTime:.status.resources[?(@.name=="api-descriptors")].conditions[?(@.reason=="Ready")].lastTransitionTime')
echo "${apid_wld_status_lastime}" | awk '{ printf("  %s\n", $0) }'

## Config Writer
echo '------------------------------'
echo 'Config Writer'
echo '------------------------------'
cw=$(kubectl -n ${ns} get runnable ${wld}-config-writer-pull-requester \
-o custom-columns='Runnable NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,LAST_TRANSITION:.status.conditions[-1].lastTransitionTime')
echo "${cw}" | awk '{ printf("  %s\n", $0) }'
write_taskruns1=$(kubectl -n ${ns} get taskruns -l carto.run/workload-name=${wld} -l app.kubernetes.io/component=config-writer-pull-requester -o 'jsonpath={.items[-1].metadata.name}' --sort-by='.metadata.creationTimestamp')
cw_write_taskruns1=$(kubectl -n ${ns} get taskruns ${write_taskruns1} \
-o custom-columns='Last_TaskRuns NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,COMPLETION_TIME:.status.completionTime')
echo "${cw_write_taskruns1}" | awk '{ printf("    %s\n", $0) }'

## Pull Config
echo '------------------------------'
echo 'Pull Config'
echo '------------------------------'
pc=$(kubectl -n ${ns} get gitrepo ${wld}-delivery \
-o custom-columns='GitRepo NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,LAST_TRANSITION:.status.conditions[-1].lastTransitionTime')
echo "${pc}" | awk '{ printf("  %s\n", $0) }'

## Delivery
echo '------------------------------'
echo 'Delivery'
echo '------------------------------'
de=$(kubectl -n ${ns} get app ${wld} \
-o custom-columns='App NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,LastMornitorAt:.status.deploy.updatedAt')
echo "${de}" | awk '{ printf("  %s\n", $0) }'

## Application Running
echo '------------------------------'
echo 'Application Running'
echo '------------------------------'
ar=$(kubectl -n ${ns} get deployment \
-l carto.run/workload-name=${wld},app.kubernetes.io/component=run \
-o custom-columns='Application Deploy NAME:.metadata.name,CREATION_TIME:.metadata.creationTimestamp,LAST_TRANSITION:.status.conditions[-1].lastUpdateTime')
echo "${ar}" | awk '{ printf("  %s\n", $0) }'

## Summay
#!/bin/bash

calculate_time_difference() {
    local time1=$1
    local time2=$2

    # local timestamp1=$(date -u "$time1" +"%s")
    # local timestamp2=$(date -u "$time2" +"%s")
    local timestamp1=$(date -ju -f "%Y-%m-%dT%H:%M:%SZ" "$time1" "+%s")
    local timestamp2=$(date -ju -f "%Y-%m-%dT%H:%M:%SZ" "$time2" "+%s")

    local difference=$((timestamp2 - timestamp1))
    echo "($difference Seconds)"
}

echo '================================================================'
echo 'SUMMARY'
echo '================================================================'
sp_last_time=$(kubectl -n ${ns} get gitrepo ${wld} \
-o jsonpath='{.status.conditions[-1].lastTransitionTime}')

st_test_pipelineruns1_starttime=$(kubectl -n ${ns} get pipelineruns ${test_pipelineruns1} \
-o jsonpath='{.metadata.creationTimestamp}')
st_test_pipelineruns1_endtime=$(kubectl -n ${ns} get pipelineruns ${test_pipelineruns1} \
-o jsonpath='{.status.completionTime}')
gap_st=$(calculate_time_difference ${st_test_pipelineruns1_starttime} ${st_test_pipelineruns1_endtime})

sc_scan_taskruns1_starttime=$(kubectl -n ${ns} get taskruns ${scan_taskruns1} \
-o jsonpath='{.metadata.creationTimestamp}')
sc_scan_taskruns1_endtime=$(kubectl -n ${ns} get taskruns ${scan_taskruns1} \
-o jsonpath='{.status.completionTime}')
gap_sc=$(calculate_time_difference ${sc_scan_taskruns1_starttime} ${sc_scan_taskruns1_endtime})


build1pod_starttime=$(kubectl -n ${ns} get pod -l carto.run/workload-name=${wld} -l kpack.io/build=${builds1} \
-o jsonpath='{.items[0].metadata.creationTimestamp}') 
build1pod_endtime=$(kubectl -n ${ns} get pod -l carto.run/workload-name=${wld} -l kpack.io/build=${builds1} \
-o jsonpath='{.items[0].status.containerStatuses[?(@.name=="completion")].state.terminated.finishedAt'})
gap_build=$(calculate_time_difference ${build1pod_starttime} ${build1pod_endtime})

is_imagescan_taskruns1_starttime=$(kubectl -n ${ns} get taskruns ${imagescan_taskruns1} \
-o jsonpath='{.metadata.creationTimestamp}')
is_imagescan_taskruns1_endtime=$(kubectl -n ${ns} get taskruns ${imagescan_taskruns1} \
-o jsonpath='{.status.completionTime}')
gap_is=$(calculate_time_difference ${is_imagescan_taskruns1_starttime} ${is_imagescan_taskruns1_endtime})

cp_wld_status_endtime=$(kubectl -n ${ns} get wld ${wld} \
-o jsonpath='{.status.resources[?(@.name=="config-provider")].conditions[?(@.reason=="Ready")].lastTransitionTime}')

ac_wld_status_endtime=$(kubectl -n ${ns} get wld ${wld} \
-o jsonpath='{.status.resources[?(@.name=="app-config")].conditions[?(@.reason=="Ready")].lastTransitionTime}')

sb_wld_status_endtime=$(kubectl -n ${ns} get wld ${wld} \
-o jsonpath='{.status.resources[?(@.name=="service-bindings")].conditions[?(@.reason=="Ready")].lastTransitionTime}')

apid_wld_status_endtime=$(kubectl -n ${ns} get wld ${wld} \
-o jsonpath='{.status.resources[?(@.name=="api-descriptors")].conditions[?(@.reason=="Ready")].lastTransitionTime}')

cw_write_taskruns1_starttime=$(kubectl -n ${ns} get taskruns ${write_taskruns1} \
-o jsonpath='{.metadata.creationTimestamp}')
cw_write_taskruns1_endtime=$(kubectl -n ${ns} get taskruns ${write_taskruns1} \
-o jsonpath='{.status.completionTime}')
gap_cw=$(calculate_time_difference ${cw_write_taskruns1_starttime} ${cw_write_taskruns1_endtime})

pc_last_time=$(kubectl -n ${ns} get gitrepo ${wld}-delivery \
-o jsonpath='{.status.conditions[-1].lastTransitionTime}')

ar_last_time=$(kubectl -n ${ns} get deployment \
-l carto.run/workload-name=${wld},app.kubernetes.io/component=run \
-o jsonpath='{.items[0].status.conditions[-1].lastUpdateTime}')

gap_total=$(calculate_time_difference ${sp_last_time} ${ar_last_time})

echo 'Source  Provider   ' ${sp_last_time}
echo 'Source  Tester     ' ${st_test_pipelineruns1_starttime} ${st_test_pipelineruns1_endtime}   ${gap_st}     
echo 'Source  Scaner     ' ${sc_scan_taskruns1_starttime} ${sc_scan_taskruns1_endtime}           ${gap_sc}         
echo 'Image   Provider   ' ${build1pod_starttime} ${build1pod_endtime}                           ${gap_build}        
echo 'Image   Scanner    ' ${is_imagescan_taskruns1_starttime} ${is_imagescan_taskruns1_endtime} ${gap_is} 
echo 'Config  Provider   ' ${cp_wld_status_endtime}                                         
echo 'App     Config     ' ${ac_wld_status_endtime}
echo 'Service Bindings   ' ${sb_wld_status_endtime}
echo 'Api     Descriptors' ${apid_wld_status_endtime}
echo 'Config  Writer     ' ${cw_write_taskruns1_starttime} ${cw_write_taskruns1_endtime}         ${gap_cw}
echo 'Pull    Config     ' ${pc_last_time}
echo 'App     Deploy     ' ${ar_last_time}
echo 'TOTAL' ${gap_total}