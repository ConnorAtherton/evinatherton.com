// = require 'animate.js'

(function () {
  var defaultPerspective = 800

  function delta(evt, bounds) {
    var a = {
      x: evt.clientX - bounds.left - bounds.width / 2,
      y: evt.clientY - bounds.top - bounds.height / 2
    }

    console.log(a)

    return {
      x: a.x * (1 - Math.abs(a.x) / bounds.width) * .2,
      y: a.y * (1 - Math.abs(a.y) / bounds.height) * .2
    }
  }

  document.addEventListener("DOMContentLoaded", function() {
    Array.from(document.querySelectorAll('.c-small-card')).forEach(function (card, i) {
      var bounds = card.getBoundingClientRect()

      // function update (evt) {
      //   var rotate = delta(evt, bounds)
      //   card.style.transform = "perspective(" + defaultPerspective + "px) rotateX(" + rotate.x + "deg) rotateY(" + -rotate.y + "deg)"
      // }

      function addRotations (evt) {
        console.log('[addRotations] delta')
        var rotate = delta(evt, bounds)

        console.log('=> adding rotation', rotate)

        animate({
          el: card,
          perspective: [defaultPerspective, defaultPerspective],
          rotateX: rotate.x,
          rotateY: -rotate.y,
          easing: "easeOutQuad",
          duration: 150,
          // complete: function() {
          //   return card.addEventListener("mousemove", update)
          // }
        })
      }

      // card.addEventListener("mouseleave", function(evt) {
      //   card.setAttribute("style", "")
      // })

      card.addEventListener("mouseenter", addRotations)

     card.addEventListener("mouseleave", function(evt) {
        console.log('[mouseleave] delta')
        var rotate = delta(evt, bounds)

        animate({
          el: card,
          perspective: [800, 800],
          rotateX: [rotate.x, 0],
          rotateY: [-rotate.y, 0],
          easing: "easeOutCubic 400",
          duration: 250,
          // complete: function() {
          //   return card.removeEventListener("mousemove", update)
          // }
        })
      })
    })
  })
})()
