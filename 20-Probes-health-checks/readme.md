## Probes check
A **probe** is a health check that can be configured to check the health of the containers running in a pod.  
A probe can be used to determine whether a container is running or ready to receive requests. A probe may return the following results:

> **Success**: The container passed the health check.
> **Failure**: The container failed the health check.
> **Unknown**: The health check failed for unknown reasons.

## Types of probe
### Liveness Probe
This is a health check that's used to determine whether a particular container is running or not. If a container fails the liveness probe, the controller will try to restart the pod on the same node according to the restart policy configured for the pod.

### Readiness Probe
This is a health check that's used to determine whether a particular container is ready to receive requests or not. How we define the readiness of a container depends largely on the application running inside the container.

## Setttings of Probes

> **initialDelaySeconds**: Number of seconds after the container has started before liveness or readiness probes are initiated. Defaults to 0 seconds. Minimum value is 0.  
> **periodSeconds**: How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.  
> **timeoutSeconds**: Number of seconds after which the probe times out. Defaults to 1 second. Minimum value is 1.  
> **successThreshold**: Minimum consecutive successes for the probe to be considered successful after having failed. Defaults to 1. Must be 1 for liveness. Minimum value is 1.  
> **failureThreshold**: When a probe fails, Kubernetes will try failureThreshold times before giving up. Giving up in case of liveness probe means restarting the container. In case of readiness probe the Pod will be marked Unready. Defaults to 3. Minimum value is 1.  

### HTTP probes have additional fields that can be set on httpGet:
> **host**: Host name to connect to, defaults to the pod IP. You probably want to set "Host" in httpHeaders instead.  
> **scheme**: Scheme to use for connecting to the host (HTTP or HTTPS). Defaults to HTTP.  
> **path**: Path to access on the HTTP server.
httpHeaders: Custom headers to set in the request. HTTP allows repeated headers.  
> **port**: Name or number of the port to access on the container. Number must be in the range 1 to 65535.  




