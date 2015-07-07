$ ->
  return unless $('.show.admin_metrics').length

  console.log window.datapoints

  graph = d3.select('#d3chart')

  margin = {top: 25, right: 5, bottom: 20, left: 75}

  main = graph.append("g")
    .attr("transform", "translate(#{margin.left},#{margin.top})")

  maxX = graph[0][0].getBoundingClientRect().width
  maxY = graph[0][0].getBoundingClientRect().height

  width  = maxX - margin.left - margin.right
  height = maxY - margin.top - margin.bottom

  x = d3.time.scale().range([0, width])
    .domain(d3.extent(datapoints, (d) -> d.date))
  y = d3.scale.linear().range([0, height])
    .domain([
      d3.max(datapoints, (d) -> d.value),
      d3.min(datapoints, (d) -> d.value)
    ])

  syAxis = d3.svg.axis().scale(y).orient("left")
  sxAxis = d3.svg.axis().scale(x).orient("bottom")
    .ticks(d3.time.days, 10)
    .tickFormat(d3.time.format('%b %d'))

  valueline = d3.svg.line()
    .x((d) -> x(d.date))
    .y((d) -> y(d.value))

  main.append("path")
    .attr("class", "line")
    .attr("d", valueline(datapoints));

  main.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0,#{height})")
    .call(sxAxis)

  main.append("g")
    .attr("class", "y axis")
    .call(syAxis)
