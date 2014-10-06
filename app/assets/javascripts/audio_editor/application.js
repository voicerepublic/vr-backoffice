//= require d3

var audioCutter = angular.module('AudioCutter', []);

var saveRevisions = function(revisions) {
  $.ajax(updateUrl, {
    type: 'PATCH',
    dataType: 'json',
    data: { talk: { edit_config: JSON.stringify(revisions) } } });
};

// constants
var margin = {
	top : 20,
	right : 20,
	bottom : 30,
	left : 50
},
width = 10000 - margin.left - margin.right,
height = 150 - margin.top - margin.bottom;

var parseDate = d3.time.format("%d-%b-%y").parse;
var offsetX = 50;

audioCutter.controller('AudioController', ['$scope', '$http', function ($scope, $http) {

			$scope.file = {
				url : audioFile
			};

			$scope.playerButtonLabel = 'Play';
			$scope.revisions = revisions;

			var contextClass = (window.AudioContext ||
				window.webkitAudioContext ||
				window.mozAudioContext ||
				window.oAudioContext ||
				window.msAudioContext);
			if (contextClass) {
				// Web Audio API is available.
				var audioContext = new contextClass();
			}

			var loadData = function () {
				delete $http.defaults.headers.common['X-Requested-With'];
				$http.get($scope.file.url, {
					responseType : "arraybuffer",
          headers: {
              'Access-Control-Allow-Origin': '*'
          }
				}).success(function (response) {
					audioContext.decodeAudioData(response, function (buffer) {
						//var source = context.createBufferSource();
						//source.buffer = buffer;
						//$scope.source = source;
						$scope.file.duration = buffer.duration;
						var leftChannel = buffer.getChannelData(0); // Float32Array describing left channel
						var downSize = new Array();
						var reSizeFactor = parseInt(leftChannel.length / 10000);
						for (var i = 0; i < leftChannel.length; i += reSizeFactor) {
							downSize[i / reSizeFactor] = leftChannel[i];

						}
						$scope.duration = buffer.duration;
						$scope.data = downSize;
						$scope.$apply();
					});
				});

			}

			$scope.playFile = function () {
				var oAudio = document.getElementById("audio1");
				if (oAudio.paused) {
					$scope.playerButtonLabel = 'Pause';
					oAudio.play();
				}else {
					$scope.playerButtonLabel = 'Play';
					oAudio.pause();
				}
			};

			$scope.saveRevision = function(){			
				$scope.revisions[$scope.revisions.length] = JSON.parse(JSON.stringify($scope.cutConfig));				
				//todo call save method;
				//saveRevisions($scope.revisions);
			}
			
			$scope.returnToRevision = function(index){
				if($scope.revisions.length > 0){
					$scope.cutConfig = JSON.parse(JSON.stringify($scope.revisions[index]));					
					$scope.rePaintCutConfigs();
				}
			}

			$scope.rePaintCutConfigs = function(){
				var svg = d3.select("svg");
				//svg.selectAll(".cut-config").remove();				
				var rects = svg.selectAll(".cut-config").data($scope.cutConfig)
				rects.enter().append("g")
						.attr("class", "cut-config")
						.style("opacity", 0.4)
						.append("rect")
						.attr("x", function(d){
							return d.start / $scope.duration * width + margin.left;
						}).attr("width", function(d){
							return d.end / $scope.duration * width - d.start / $scope.duration * width;
						}).attr("y", margin.top).attr("height", height);
				rects.exit().remove();
			}

			$scope.currentTime;

			$scope.cutConfig = new Array();

			loadData();

		}
	]);

audioCutter.directive('waveform', function () {
	return {
		restrict : 'E',
		scope : false,
		link : function (scope, element, attrs) {

			// set up initial svg object
			var svg = d3.select(element[0])
				.append("svg")
				.attr("width", width + margin.left + margin.right)
				.attr("height", height + margin.top + margin.bottom)
				.append("g")
				.attr("transform", "translate(" + margin.left + "," + margin.top + ")")

				var mouseDown = false;
			//variable to keep last mousedown event
			var xMouseDown = -1;
			//Array Containing the cutting positions
			var cutConfig = new Array();
			// Hover line.
			var hoverLineGroup = svg.append("g")
				.attr("class", "hover-line");
			var hoverLine = hoverLineGroup
				.append("line")
				.attr("x1", 10).attr("x2", 10)
				.attr("y1", 0).attr("y2", height);
			// Hide hover line by default.
			hoverLine.style("opacity", 1e-6);

			//Move the hoverline with the cursor
			d3.select(".inner").on("mouseover", function () {
				var x = d3.mouse(this)[0] - margin.left;
				hoverLine.attr("x1", x).attr("x2", x).style("opacity", 1);
			}).on("mousemove", function () {

				var x = d3.mouse(this)[0] - margin.left;
				hoverLine.attr("x1", x).attr("x2", x).style("opacity", 1);
			}).on("mouseout", function () {
				hoverLine.style("opacity", 1e-6);
			});

			//OnMousedown event
			//set xMouseDown and remove if there is a configuration avaiable
			d3.select(".inner").on("mousedown", function () {
				if(scope.data == null){
					return;
				}
				xMouseDown = (d3.mouse(this)[0]- margin.left) / width * scope.duration;
				for (var i = 0; i < scope.cutConfig.length; i++) {
					if (scope.cutConfig[i].start <= xMouseDown && scope.cutConfig[i].end >= xMouseDown) {
						scope.cutConfig.splice(i, 1);
						scope.rePaintCutConfigs();
						xMouseDown = -1;
						return true;
					}

				}
				d3.event.preventDefault();
			}).on("mouseup", function () {
				//OnMouseup event. create a new CutConfiguration and save it to the array.
				if (xMouseDown == -1) {
					return true;
				}
				var xOut = (d3.mouse(this)[0] - margin.left) / width * scope.duration;
				var currentCutConfig = new Object();
				if (xMouseDown < xOut) {
					currentCutConfig.start = xMouseDown;
					currentCutConfig.end = xOut;
				} else {
					currentCutConfig.start = xOut;
					currentCutConfig.end = xMouseDown;
				}
				console.log(currentCutConfig.start);
				console.log(currentCutConfig.end);
				scope.cutConfig[scope.cutConfig.length] = currentCutConfig;
				console.log(scope.cutConfig.length);
				scope.rePaintCutConfigs();
				xMouseDown = -1;
			});
			/*.on("mouseleave", function () {
				if (xMouseDown == -1) {
					return true;
				}
				var xOut = (d3.mouse(this)[0] - margin.left) / width * scope.duration;
				var currentCutConfig = new Object();
				currentCutConfig.Start = xMouseDown;
				currentCutConfig.End = xOut;
				console.log(currentCutConfig.Start);
				console.log(currentCutConfig.End);
				scope.cutConfig[scope.cutConfig.length] = currentCutConfig;
				console.log(scope.cutConfig.length);
				scope.rePaintCutConfigs()
				xMouseDown = -1;
			}); */

			//Return the end of the current cut
			function GetCurrentPositionCut(currentPosition) {
				for (var i = 0; i < scope.cutConfig.length; i++) {
					if (scope.cutConfig[i].start <= currentPosition && scope.cutConfig[i].end >= currentPosition) {
						return scope.cutConfig[i].end;
					}
				}
				return currentPosition;
			}

			setInterval(function () {
				var oAudio = document.getElementById("audio1");
				if (oAudio.paused) {
					return true;
				}
				currentTime = oAudio.currentTime.toFixed(2);
				scope.currentTime = currentTime;
				scope.$apply();
				var jumpTime = GetCurrentPositionCut(currentTime);
				if (jumpTime != currentTime) {					
					scope.currentTime = jumpTime;
					scope.$apply();
					oAudio.currentTime = jumpTime;										
				}
				var totaltime = oAudio.duration;
				var res = scope.currentTime / totaltime * width
					hoverLine.attr("x1", res).attr("x2", res).style("opacity", 1);
			}, 500);

			scope.$watch('data', function (downSize, oldVal) {
				if (!downSize) {
					return;
				}
				var x = d3.scale.linear().range([0, width]),
				y = d3.scale.linear().range([height, 0]),
				xAxis = d3.svg.axis().scale(x).ticks(scope.duration);
				// yAxis = d3.svg.axis().scale(y).ticks(4).orient("right");

				//x.domain([0, waveform.adapter.length]).rangeRound([0, 1024]);
				x.domain([0, downSize.length]);
				y.domain([d3.min(downSize), d3.max(downSize)]).rangeRound([offsetX, -offsetX]);

				svg.append("g")
				.attr("class", "x axis")
				.call(xAxis);

				// svg.append("g")
				// .attr("class", "y axis")
				// .call(yAxis)

				var area = d3.svg.area()
					.interpolate("monotone")
					.x(function (d, i) {
						return x(i)
					})
					.y0(function (d, i) {
						return y(0)
					})
					.y1(function (d, i) {
						return y(d)
					});

				svg.append("path")
				.datum(downSize)
				.attr("transform", function () {
					return "translate(0, " + offsetX + ")";
				})
				.attr("d", area)

			}, true);
		}
	}
});
