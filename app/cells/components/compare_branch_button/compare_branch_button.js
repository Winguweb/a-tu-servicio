ATSB.Components['components/compare-branch-button'] = function(options) {
  new Vue({
    el: '.compare-branch-button-cell',
    data: {
      actions: {show: false},
      compared_stack: [],
      action: 'compare',
      compared_objects: {
        right: null,
        left: null
      }
    },
    created: function() {
      ATSB.pubSub.$on('branch:compare:button:show', this.compareButtonShow)
      ATSB.pubSub.$on('branch:compare:button:hide', this.compareButtonHide)
      ATSB.pubSub.$on('branch:compare:set', this.setBranchToCompare)
      ATSB.pubSub.$on('branch:compare:load:right', this.loadCompareRight)
      ATSB.pubSub.$on('branch:compare:load:left', this.loadCompareLeft)
      ATSB.pubSub.$on('branch:compare:remove', this.removeBranchToCompare)
    },
    watch: {},
    methods: {
      compareFirstStep: function() {
        this.action = 'cancel'
        ATSB.pubSub.$emit('all:slides:close')
        ATSB.pubSub.$emit('branch:list:half-right:open')
        ATSB.pubSub.$emit('branch:detail:half-left:open')
        ATSB.pubSub.$emit('branch:detail:half-left:fetch', this.compared_stack[0])
      },
      setBranchToCompare: function(id) {
        this.compared_stack.push(id)
      },
      loadCompareRight: function(branch) {
        this.compared_objects.right = branch
        ATSB.pubSub.$emit('branch:compare:colors', this.compared_objects)
      },
      loadCompareLeft: function(branch) {
        this.compared_objects.left = branch
      },
      removeBranchToCompare: function() {
        this.compared_stack.pop()
      },
      compareButtonShow: function() {
        this.action = 'compare'
        this.actions.show = true
      },
      compareButtonHide: function() {
        this.compared_stack = []
        this.actions.show = false
      },
      compareButtonClicked: function() {
        this.compareFirstStep()
      },
      compareCancelButtonClicked: function() {
        this.compareButtonHide()
        ATSB.pubSub.$emit('all:slides:close')
        ATSB.pubSub.$emit('branch:list:large:open')
      }
    }
  })
}
