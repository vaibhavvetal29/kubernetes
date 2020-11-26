-o jsonpath

whole query ''

we have query in 
{}

Query 

first {} represent as .


array=["dinesh","kundan","ajinkya","vaibhav"]

array[2]

## get all contaienr names
kubectl get pod -o jsonpath='{.items[*].metadata.name}'

## get first 6 container
kubectl get pod -o jsonpath='{.items[0:5].metadata.name}'

to get first 5 [0:4]

## get all pods container images
kubectl get pod -o jsonpath='{.items[*].spec.containers[*].image}'

## get count
### count lines
kubectl get pods | wc -l

### count words
kubectl get pod -o jsonpath='{.items[*].spec.containers[*].image}' | wc -w


## Get specific columns

kubectl get pod -o jsonpath='{range .items[*]}{@.metadata.name}{"\t"}{@.status.phase}{"\n"}{end}'

{range .items[*]}     {@.metadata.name}   {@.status.phase}


## give me container names and images 

kubectl get pod -n kube-system -o jsonpath='{range .items[*].spec.containers[*]}{@.name}:{@.image}{"\n"}'

kubectl get pod -n kube-system -o jsonpath='{range .items[*]}{@.spec.containers[*].name}:{@.spec.containers[*].image}{"\n"}'






kubectl get pod -o jsonpath='{.items[*].spec.containers[*].image}' | wc -w
 1043  clear
 1044  kubectl get pod nginx -o jsonpath='{.items[*].status}'
 1045  kubectl get pod nginx -o jsonpath='{.items[].status}'
 1046  kubectl get pod nginx -o jsonpath='{.status}'
 1047  clear
 1048  kubectl get pod nginx -o jsonpath-as-json='{.status}'
 1049  clear
 1050  kubectl get pod nginx -o yaml | grep -i phase
 1051  kubectl get pod nginx -o yaml | grep -i Running
 1052  clear
 1053  kubectl get pod nginx -o jsonpath-as-json='{.status}'
 1054  clear
 1055  kubectl get pod nginx -o jsonpath-as-json='{.status.phase}'
 1056  kubectl get pod -o jsonpath-as-json='{.items[*].status.phase}'
 1057  clear
 1058  kubectl get pod -o custom-columns=NAME:.metadata.name,STATUS:.status.phase
 1059  kubectl get pod nginx -o jsonpath='{.status}'
 1060  clear
 1061  kubectl get pod -o jsonpath='{.items[*].metadata.name .items[*].status.phase}'
 1062  kubectl get pod -o jsonpath='{.items[*].metadata.name,.items[*].status.phase}'
 1063  kubectl get pod -o jsonpath='{.items[*].metadata.name} {.items[*].status.phase}'
 1064  kubectl get pod -o jsonpath='{range .items[*]}{@.metadata.name}'
 1065  kubectl get pod -o jsonpath='{range .items[*]}{@.metadata.name}{@.status.phase}'
 1066  kubectl get pod -o jsonpath='{range .items[*]}{@.metadata.name} {@.status.phase}'
 1067  kubectl get pod -o jsonpath='{range .items[*]}{@.metadata.name} {@.status.phase}{"\n"}'
 1068  kubectl get pod -o jsonpath='{range .items[*]}{@.metadata.name}{"\t"}{@.status.phase}{"\n"}'
 1069  kubectl get pod -o jsonpath='{range .items[*]}{@.metadata.name}:{@.status.phase}{"\n"}'
 1070  clear
 1071  kubectl get pod -o jsonpath='{range .items[*]}{@.spec.containers[].name}:{@.spec.containers[].image}{"\n"}'
 1072  kubectl get pod -n kube-system -o jsonpath='{range .items[*]}{@.spec.containers[].name}:{@.spec.containers[].image}{"\n"}'
 1073  kubectl get pods -n kube-system -o wide
 1074  kubectl describe pods weave-net-5z5hd -n kube-system
 1075  clear
 1076  kubectl get pod -n kube-system -o jsonpath='{range .items[*]}{@.spec.containers[].name}:{@.spec.containers[].image}{"\n"}'
 1077  kubectl get pod -n kube-system -o jsonpath='{range .items[*]}{@.spec.containers[*].name}:{@.spec.containers[*].image}{"\n"}'
 1078  kubectl get pod -n kube-system -o jsonpath='{range .items[*]}{@.spec.containers[*].name}:{@.spec.containers[*].image}{"\n"}'clear
 1079  clear
 1080  kubectl get pod -n kube-system -o jsonpath='{range .items[*].spec.containers[*]}{@.name}:{@.image}{"\n"}'clear
 1081  kubectl get pod -n kube-system -o jsonpath='{range .items[*].spec.containers[*]}{@.name}:{@.image}{"\n"}'
 1082  clear
 1083  kubectl config view
 1084  clear
 1085  kubectl config view -o jsonpath='{}'
 1086  kubectl config view
 1087  kubectl config view -o jsonpath='{.users[*].name}'
 1088  clear
 1089  kubectl config view -o jsonpath='{.users[*].name}'
 1090  clear
 1091  kubectl config view -o jsonpath='{.users[*].name}'
 1092  kubectl config --help
 1093  clear
 1094  kubectl config get-contexts
 1095  clear
 1096  kubectl get nodes
 1097  kubectl get nodes -o json | less
 1098  kubectl get nodes -o jsonpath='{.items[*].spec.taints[*].}'
 1099  kubectl get nodes -o json | less
 1100  kubectl get nodes -o json | grep -B 5 -A 5 -i taints
 1101  kubectl get nodes -o jsonpath='{.items[*].spec.taints[*].effect}'
 1102  clear
 1103  kubectl get nodes -o jsonpath='{.items[*].spec.taints[*].effect}'
 1104  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadat.name}{end}'
 1105  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}{end}'
 1106  clear
 1107  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}{"\n"}{end}'
 1108  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}{@.spec.taints[*].effetc}{"\n"}{end}'
 1109  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}{@.spec.taints[*].effect}{"\n"}{end}'
 1110  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{@.spec.taints[*].effect}{"\n"}{end}'
 1111  clear
 1112  kubectl config view
 1113  history
 1114  clear
 1115  history
 1116  clear
 1117  kubectl config view -o jsonpath='{.users[*].name}'
 1118  clear
 1119  kubectl config view -o jsonpath='{.users[?(@.name == "prashant")].name}'
 1120  clear
 1121  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{@.spec.taints[?(@.effect != "")].effect}{"\n"}{end}'
 1122  kubectl get nodes -o json | grep -B 5 -A 5 -i taints
 1123  clear
 1124  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{@.spec.taints[?(@.effect == "Noschedule")].effect}{"\n"}{end}'
 1125  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{@.spec.taints[?(@.effect == "NoSchedule")].effect}{"\n"}{end}'
 1126* kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{@.spec.}{"\n"}{end}'
 1127  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{@.spec.taints[?(@.effect == "NoSchedule")].effect}{"\n"}{end}'
 1128  kubectl get nodes -o jsonpath='{range .items[*]}:{@.spec.taints[?(@.effect == "NoSchedule")].effect}{"\n"}{end}'
 1129  kubectl get nodes -o jsonpath='{range .items[*]}{@.spec.taints[?(@.effect == "NoSchedule")].effect}{"\n"}{end}'
 1130  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{@.spec.taints[?(@.effect != "")].effect}{"\n"}{end}'
 1131  kubectl get nodes -o jsonpath='{range .items[*]}{@.spec.taints[?(@.effect == "NoSchedule")].effect}{"\n"}{end}'
 1132  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{@.spec.taints[?(@.effect == "NoSchedule")].effect}{"\n"}{end}'
 1133  clear
 1134  kubectl get nodes -o jsonpath='{.items[*].spec.taints[?(@.effect == "NoSchedule")]}'
 1135  kubectl get nodes -o jsonpath='{.items[*].spec.taints[?(@.effect == "NoSchedule")]}{"\n"}'
 1136  kubectl get nodes -o jsonpath='{range .items[*].spec.taints[?(@.effect == "NoSchedule")]}'
 1137* kubectl get nodes -o jsonpath='{range .items[*].spec.taints[?(@.effect == "NoSchedule")]}{@.effect}'
 1138  kubectl get nodes -o jsonpath='{range .items[*].spec.taints[?(@.effect == "NoSchedule")].effect}'
 1139  kubectl get nodes -o jsonpath='{.items[*].spec.taints[?(@.effect == "NoSchedule")].effect}'
 1140  clear
 1141  kubectl get nodes -o jsonpath='{.items[*].spec.taints[?(@.effect == "NoSchedule")].effect}'
 1142  kubectl get nodes -o jsonpath='{range .items[*]}'
 1143  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}{end}'
 1144  kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}{"\n"}{end}'
 1145  kubectl get nodes -o jsonpath='{range .items[*].spec.taints[?(@.effect == "NoSchedule")}{@.metadata.name}{"\n"}{end}'
 1146  kubectl get nodes -o jsonpath='{range .items[?(.spec.taints.effect == "NoSchedule")]}{@.metadata.name}{"\n"}{end}'
 1147  kubectl get nodes -o jsonpath='{range .items[?(.spec.taints[0].effect == "NoSchedule")]}{@.metadata.name}{"\n"}{end}'
 1148  clear
 1149  kubectl get nodes -o jsonpath='{range .items[?(.spec.taints[0].effect == "NoSchedule")]}{@.metadata.name}{"\n"}{end}'
 1150  kubectl get nodes -o jsonpath='{range .items[?(.spec.taints[0].effect == "NoSchedule")]}{@.metadata.name}{@.spec.taints[*].effect}{"\n"}{end}'
 1151  kubectl get nodes -o jsonpath='{range .items[?(.spec.taints[0].effect == "NoSchedule")]}{@.metadata.name}:{@.spec.taints[*].effect}{"\n"}{end}'
 1152  kubectl get nodes -o jsonpath='{range .items[?(.spec.taints[0].effect == "NoSchedule")]}{@.metadata.name}:{@.spec.taints[*].effect}{"\n"}{end}' > nodes.txt
 1153  history


