prometheus-operator tests
=========================

## Port forward to the prometheus server

```
kubectl -n monitoring port-forward service/prometheus-operated 9090
```

## Check to make sure the Prometheus GUI is running

```
2wire609-v:environment-creation garlandkan$ curl http://localhost:9090/graph -v
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 9090 (#0)
> GET /graph HTTP/1.1
> Host: localhost:9090
> User-Agent: curl/7.54.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Wed, 16 Sep 2020 18:33:10 GMT
< Content-Type: text/html; charset=utf-8
< Transfer-Encoding: chunked
< 
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta name="robots" content="noindex,nofollow">
        <title>Prometheus Time Series Collection and Processing Server</title>
        <link rel="shortcut icon" href="/static/img/favicon.ico?v=18254838fbe25dcc732c950ae05f78ed4db1292c">
        <script src="/static/vendor/js/jquery-3.3.1.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>    
        <script src="/static/vendor/js/popper.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
        <script src="/static/vendor/bootstrap-4.3.1/js/bootstrap.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
        <link type="text/css" rel="stylesheet" href="/static/vendor/bootstrap-4.3.1/css/bootstrap.min.css?v=18254838fbe25dcc732c950ae05f78ed4db1292c">
        <link type="text/css" rel="stylesheet" href="/static/css/prometheus.css?v=18254838fbe25dcc732c950ae05f78ed4db1292c">
        <link type="text/css" rel="stylesheet" href="/static/vendor/bootstrap4-glyphicons/css/bootstrap-glyphicons.min.css?v=18254838fbe25dcc732c950ae05f78ed4db1292c">
        <script>
            var PATH_PREFIX = "";
            var BUILD_VERSION = "18254838fbe25dcc732c950ae05f78ed4db1292c";
            $(function () {
                $('[data-toggle="tooltip"]').tooltip()
            })
        </script>
    <link type="text/css" rel="stylesheet" href="/static/vendor/rickshaw/rickshaw.min.css?v=18254838fbe25dcc732c950ae05f78ed4db1292c">
    <link type="text/css" rel="stylesheet" href="/static/vendor/eonasdan-bootstrap-datetimepicker/bootstrap-datetimepicker.min.css?v=18254838fbe25dcc732c950ae05f78ed4db1292c">
    <script src="/static/vendor/rickshaw/vendor/d3.v3.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/vendor/rickshaw/vendor/d3.layout.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/vendor/rickshaw/rickshaw.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/vendor/moment/moment.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/vendor/moment/moment-timezone-with-data.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/vendor/eonasdan-bootstrap-datetimepicker/bootstrap-datetimepicker.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/vendor/bootstrap3-typeahead/bootstrap3-typeahead.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/vendor/fuzzy/fuzzy.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/vendor/mustache/mustache.min.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/vendor/js/jquery.selection.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script src="/static/js/graph/index.js?v=18254838fbe25dcc732c950ae05f78ed4db1292c"></script>
    <script id="graph_template" type="text/x-handlebars-template"></script>
    <link type="text/css" rel="stylesheet" href="/static/css/graph.css?v=18254838fbe25dcc732c950ae05f78ed4db1292c">
    </head>
    <body>
        <nav class="navbar fixed-top navbar-expand-sm navbar-dark bg-dark">
            <div class="container-fluid">      
                <button type="button" class="navbar-toggler" data-toggle="collapse" data-target="#nav-content" aria-expanded="false" aria-controls="nav-content" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <a class="navbar-brand" href="/">Prometheus</a>
                <div id="nav-content" class="navbar-collapse collapse">
                    <ul class="navbar-nav">
                        <li class="nav-item"><a class="nav-link" href="/alerts">Alerts</a></li>
                        <li class="nav-item"><a class="nav-link" href="/graph">Graph</a></li>
                        <li class="nav-item dropdown">
                            <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Status <span class="caret"></span></a>
                            <div class="dropdown-menu">
                                <a class="dropdown-item" href="/status">Runtime &amp; Build Information</a>
                                <a class="dropdown-item" href="/flags">Command-Line Flags</a>
                                <a class="dropdown-item" href="/config">Configuration</a>
                                <a class="dropdown-item" href="/rules">Rules</a>
                                <a class="dropdown-item" href="/targets">Targets</a>
                                <a class="dropdown-item" href="/service-discovery">Service Discovery</a>
                            </div>
                        </li>
                        <li class= "nav-item" >
                            <a class ="nav-link" href="https://prometheus.io/docs/prometheus/latest/getting_started/" target="_blank">Help</a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    <div id="graph_container" class="container-fluid">
      <div class="clearfix">
        <div class="query-history">
          <i class="glyphicon glyphicon-unchecked"></i>
          <button type="button" class="search-history" title="search previous queries">Enable query history</button>
        </div>
        <button type="button" class="btn btn-link btn-sm new_ui_button" onclick="window.location.pathname='/new/graph'">Try experimental React UI</button>
      </div>
    </div>
    <div class="container-fluid">
      <div><input class="btn btn-primary" type="submit" value="Add Graph" id="add_graph"></div>
    </div>
    </body>
</html>
* Connection #0 to host localhost left intact
```

Looking for:
* HTTP status code of 200
* has title: `<title>Prometheus Time Series Collection and Processing Server</title>`

## Get metric: container_cpu_usage_seconds_total

```
2wire609-v:environment-creation garlandkan$ curl http://localhost:9090/api/v1/query?query=container_cpu_usage_seconds_total
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"container_cpu_usage_seconds_total","cpu":"total","endpoint":"http-metrics","id":"/","instance":"172.17.50.218:10255","job":"kubelet","metrics_path":"/metrics/cadvisor","node":"ip-172-17-50-218.ec2.internal","service":"monitoring-prometheus-oper-kubelet"},"value":[1600284290.672,"14998.207688423"]},{"metric":{"__name__":"container_cpu_usage_seconds_total","cpu":"total","endpoint":"http-metrics","id":"/docker/b7001493582687fefcde85a80a386a4140e465863eadc09293d9f990d9c19586","image":"protokube:1.16.4","instance":"172.17.50.218:10255","job":"kubelet","metrics_path":"/metrics/cadvisor","name":"hungry_haibt","node":"ip-172-17-50-218.ec2.internal","service":"monitoring-prometheus-oper-kubelet"},"value":[1600284290.672,"231.251747641"]},{"metric":{"__name__":"container_cpu_usage_seconds_total","cpu":"total","endpoint":"http-metrics","id":"/kubepods","instance":"172.17.50.218:10255","job":"kubelet","metrics_path":"/metrics/cadvisor","node":"ip-172-17-50-218.ec2.internal","service":"monitoring-prometheus-oper-kubelet"},"value":[1600284290.672,"4821.350812898"]},{"metric":{"__name__":"container_cpu_usage_seconds_total","cpu":"total","endpoint":"http-metrics","id":"/kubepods/besteffort","instance":"172.17.50.218:10255","job":"kubelet","metrics_path":"/metrics/cadvisor","node":"ip-172-17-50-218.ec2.internal","service":"monitoring-prometheus-oper-kubelet"},"value":[1600284290.672,"1961.084431747"]},{"metric":{"__name__":"container_cpu_usage_seconds_total","cpu":"total","endpoint":"http-metrics","id":"/kubepods/besteffort/pod827372a8-3cc9-4de0-93f4-9b23afb57943","instance":"172.17.50.218:10255","job":"kubelet","metrics_path":"/metrics/cadvisor","namespace":"app","node":"ip-172-17-50-218.ec2.internal","pod":"consul-server-2","service":"monitoring-prometheus-oper-kubelet"},"value":[1600284290.672,"1723.278175848"]},{"metric":{"__name__":"container_cpu_usage_seconds_total","cpu":"total","endpoint":"http-metrics","id":"/kubepods/besteffort/podb4f55dc1-ae65-48e4-bd9b-44206b79c11b","instance":"172.17.50.218:10255","job":"kubelet","metrics_path":"/metrics/cadvisor","namespace":"monitoring","node":"ip-172-17-50-218.ec2.internal","pod":"prometheus-operator-prometheus-node-exporter-vkpn5","service":"monitoring-prometheus-oper-kubelet"},"value":[1600284290.672,"84.003692545"]},{"metric":{"__name__":"container_cpu_usage_seconds_total","cpu":"total","endpoint":"http-metrics","id":"/kubepods/burstable","instance":"172.17.50.218:10255","job":"kubelet","metrics_path":"/metrics/cadvisor","node":"ip-172-17-50-218.ec2.internal","service":"monitoring-prometheus-oper-kubelet"},"value":[1600284290.672,"1781.128060406"]},{"metric":{"__name__":"container_cpu_usage_seconds_total","cpu":"total","endpoint":"http-metrics","id":"/kubepods/burstable/pod4fe51041-ec70-4a61-97d4-b4137165aa6a","instance":"172.17.50.218:10255","job":"kubelet","metrics_path":"/metrics/cadvisor","namespace":"kube-system","node":"ip-172-
```

Looking for:
* A return json with the `container_cpu_usage_seconds_total` metrics


