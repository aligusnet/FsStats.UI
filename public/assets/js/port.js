AWS.config.update({region: 'us-east-1'});
AWS.config.credentials = new AWS.CognitoIdentityCredentials({IdentityPoolId: 'us-east-1:cd7e337b-aab5-4fd2-9817-c4eb0b3ab4cc'});

const lambda = new AWS.Lambda({region: 'eu-west-2', apiVersion: '2015-03-31'});

function runElmApp(nodeId, module) {
  let node = document.getElementById(nodeId);
  let app = module.embed(node);

  app.ports.fetchStats.subscribe(function(request) {
    console.log(JSON.stringify(request));
    const pullParams = {
      FunctionName : 'stats',
      InvocationType : 'RequestResponse',
      LogType : 'None',
      Payload : JSON.stringify(request)
    };

    lambda.invoke(pullParams, function(error, data) {
      if (error) {
        app.ports.fetchStatsError.send(error.message);
      } else {
        console.log(data.Payload);
        app.ports.fetchStatsSuccess.send(data.Payload);
      }
    });
  });

  app.ports.drawPlot.subscribe(function({title: title, x: x, y: y, plotId: plotId}) {
    let trace = {
      x: x,
      y: y,
      type: 'lines'
    };

    let layout = {
      title: title,
      showlegend: false,
      autosize: false,
      height: 350,
      width: 500
    };

    let config = {
      staticPlot: true
    };
    
    Plotly.newPlot(plotId, [trace], layout, config);
  });

  app.ports.clearPlot.subscribe(function(plotId) {
    document.getElementById(plotId).innerHTML = "";
  });
}

runElmApp('normal', Elm.Normal);
runElmApp('binomial', Elm.Binomial);
runElmApp('poisson', Elm.Poisson);

$(document).ready(function() {
  $('#normal-caption').click(function() {
    $('#normal').slideToggle("fast");
  });

  $('#binomial-caption').click(function() {
    $('#binomial').slideToggle("fast");
  });
  $('#poisson-caption').click(function() {
    $('#poisson').slideToggle("fast");
  });
});
