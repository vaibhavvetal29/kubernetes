## Jobs
A Job creates one or more Pods and ensures that a specified number of them successfully terminate. As pods successfully complete, the Job tracks the successful completions.
We always want to pod to be running but what if we do want the pod to terminate? There are many scenarios when you don’t want the process to keep running indefinitely.
Think of a log rotation command. Log rotation is the process of archiving (compressing) logs files that are older than a particular time threshold and deleting ancient ones
Kubernetes Jobs ensure that one or more pods execute their commands and exit successfully.
When all the pods have exited without errors, the Job gets completed. When the Job gets deleted, any created pods get deleted as well.


create a job

kubectl apply -f <file> && kubectl get pods --watch
check the output of logs








