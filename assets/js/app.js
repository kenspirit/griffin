// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import * as echarts from 'echarts'

let Hooks = {}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

Hooks.Chart = {
  mounted() {
    const gem_types = JSON.parse(this.el.dataset.gem_types)
    const locations = JSON.parse(this.el.dataset.exchange_locations)
    const overall_statistics = JSON.parse(this.el.dataset.overall_statistics)

    const option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {            // Use axis to trigger tooltip
          type: 'shadow'        // 'shadow' as default; can also be 'line' or 'shadow'
        }
      },
      legend: {
        data: gem_types
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'value'
      },
      yAxis: {
        type: 'category',
        data: locations
      },
      series: this.get_series(overall_statistics, gem_types, locations)
    };
    const chartDom = document.getElementById('chart')
    const myChart = echarts.init(chartDom)
    myChart.setOption(option)
  },
  get_series(overall_statistics, gem_types, locations) {
    return gem_types.map((gem_type) => {
      const statistics_by_gem = overall_statistics.filter((item) => {
        return item.gem_type === gem_type
      })

      return {
        name: gem_type,
        type: 'bar',
        stack: 'total',
        label: {
          show: true
        },
        emphasis: {
          focus: 'series'
        },
        data: locations.map((location) => {
          const record = statistics_by_gem.find((record) => {
            return record.location_name === location
          })
          return record ? record.total_amount : 0
        })
      }
    })
  }
}
