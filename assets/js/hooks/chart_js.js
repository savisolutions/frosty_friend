import Chart from 'chart.js/auto'

const ChartJS = {
    dataset() { return JSON.parse(this.el.dataset.chartData).data; },
    labels() { return JSON.parse(this.el.dataset.chartData).labels; },
    mounted(){
      console.log(this.el.dataset.element)
          const chart = new Chart(
            document.getElementById(this.el.dataset.element),
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
              },
              options: {
                animations: {
                  tension: {
                    duration: 1000,
                    easing: 'linear',
                    from: 1,
                    to: 0,
                    loop: true
                  }
                },
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