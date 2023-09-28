import Chart from 'chart.js/auto'

const ChartJS = {
    dataset() { return JSON.parse(this.el.dataset.chartData).data; },
    labels() { return JSON.parse(this.el.dataset.chartData).labels; },
    mounted(){
          const chart = new Chart(
            document.getElementById('chart'),
            {
              type: 'line',
              data: {
                labels: this.labels(),
                datasets: [
                  {
                    label: 'Temperature Monitoring',
                    data: this.dataset()
                  }
                ]
              }
            }
          );
          
        this.handleEvent("update-points", function(payload){ 
            chart.data.datasets[0].data = payload.data;
            chart.data.labels = payload.labels;
            chart.update();
          })
    }
}
 
export default ChartJS;