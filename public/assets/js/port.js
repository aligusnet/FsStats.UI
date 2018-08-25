AWS.config.update({region: 'us-east-1'});
AWS.config.credentials = new AWS.CognitoIdentityCredentials({IdentityPoolId: 'us-east-1:cd7e337b-aab5-4fd2-9817-c4eb0b3ab4cc'});

const lambda = new AWS.Lambda({region: 'eu-west-2', apiVersion: '2015-03-31'});

function runElmApp(nodeId, module) {
  let node = document.createElement("div");
  document.getElementById(nodeId).appendChild(node);
  let app = module.init({node: node});

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

  app.ports.drawPlot.subscribe(function({title: title, x: x, y: y, plotType: plotType, plotId: plotId}) {
    if (y.length == 0) {
      y = undefined
    }
    let trace = {
      x: x,
      y: y,
      type: plotType
    };
    

    let layout = {
      title: title,
      showlegend: false,
      autosize: false,
      height: 250,
      width: 400,
      margin: {
        l: 40,
        r: 10,
        b: 20,
        t: 55,
        pad: 4
      }
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
runElmApp('bernoulli', Elm.Bernoulli);
runElmApp('binomial', Elm.Binomial);
runElmApp('poisson', Elm.Poisson);
runElmApp('students', Elm.Students);
runElmApp('summary-statistics', Elm.SummaryStatistics);
runElmApp('onePopulationMeanTest', Elm.OnePopulationMeanTest);

$(document).ready(function() {
  $('#normal-caption').click(function() {
    $('#normal').slideToggle("fast");
  });

  $('#bernoulli-caption').click(function() {
    $('#bernoulli').slideToggle("fast");
  });

  $('#binomial-caption').click(function() {
    $('#binomial').slideToggle("fast");
  });

  $('#poisson-caption').click(function() {
    $('#poisson').slideToggle("fast");
  });

  $('#students-caption').click(function() {
    $('#students').slideToggle("fast");
  });

  $('#summary-statistics-caption').click(function() {
    $('#summary-statistics').slideToggle("fast");
  });

  $('#onePopulationMeanTest-caption').click(function() {
    $('#onePopulationMeanTest').slideToggle("fast");
  });
});
