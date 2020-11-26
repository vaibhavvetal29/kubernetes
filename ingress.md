KIND:     Ingress
VERSION:  extensions/v1beta1

RESOURCE: rules <[]Object>

DESCRIPTION:
     A list of host rules used to configure the Ingress. If unspecified, or no
     rule matches, all traffic is sent to the default backend.

     IngressRule represents the rules mapping the paths under a specified host
     to the related backend services. Incoming requests are first evaluated for
     a host match, then routed to the backend associated with the matching
     IngressRuleValue.

FIELDS:
   host	<string>
   http	<Object>
      paths	<[]Object>
         backend	<Object>
            resource	<Object>
               apiGroup	<string>
               kind	<string>
               name	<string>
            serviceName	<string>
            servicePort	<string>
         path	<string>
         pathType	<string>
