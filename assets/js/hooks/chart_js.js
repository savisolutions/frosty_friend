import Chart from "chart.js/auto";

const ChartJS = {
  dataset() {
    return JSON.parse(this.el.dataset.chartData).data;
  },
  labels() {
    return JSON.parse(this.el.dataset.chartData).labels;
  },
  mounted() {
    var config = {
      type: this.el.dataset.type,
      data: {
        labels: this.labels(),
        datasets: [
          {
            label: "Temperature",
            data: this.dataset(),
          },
        ],
      },
      options: {
        layout: {
          padding: {
            bottom: 1
          }
        },
        responsive: true,
        maintainAspectRatio: false,
        animation: {
          duration: 0
        }
      },
    };
    var chart = new Chart(document.getElementById(this.el.dataset.element), config);

    this.handleEvent("update-points", function (payload) {
      // chart.data.datasets[0].data = payload.data;
      // chart.data.labels = payload.labels;
      // chart.update();

      var ctx = document.getElementById("canvas").getContext("2d");

      // Remove the old chart and all its event handles
      if (chart) {
        chart.destroy();
      }

      // Chart.js modifies the object you pass in. Pass a copy of the object so we can use the original object later
      // var newConf = $.extend(true, {}, config);
      var newConf = JSON.parse(JSON.stringify(config));
      newConf.data.datasets[0].data = payload.data;
      newConf.data.labels = payload.labels;
      newConf.type = payload.type;
      chart = new Chart(ctx, newConf);
    });

    // this.handleEvent("update-type", function (payload) {
    //   console.log(payload);
    //   var ctx = document.getElementById("canvas").getContext("2d");

    //   // Remove the old chart and all its event handles
    //   if (chart) {
    //     chart.destroy();
    //   }

    //   // Chart.js modifies the object you pass in. Pass a copy of the object so we can use the original object later
    //   // var newConf = $.extend(true, {}, config);
    //   var newConf = JSON.parse(JSON.stringify(config));
    //   newConf.type = payload.type;
    //   chart = new Chart(ctx, newConf);
    // });
  },
};

export default ChartJS;
