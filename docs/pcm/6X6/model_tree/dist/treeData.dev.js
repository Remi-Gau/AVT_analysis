"use strict";

var treeData = [{
  "name": "Models",
  "parent": "null",
  "\_children": [// ****** S(A, V, T) ******
  {
    "name": "S(A, V, T)",
    "parent": "Models",
    "_children": [{
      "name": "S(A Ipsi, A Contra)",
      "_children": [{
        "name": "S(V Ipsi, V Contra)",
        "_children": [{
          "name": "S(T Ipsi, T Contra)"
        }]
      }]
    }, {
      "name": "I(A Ipsi, A Contra)",
      "_children": [{
        "name": "I(V Ipsi, V Contra)",
        "_children": [{
          "name": "I(T Ipsi, T Contra)"
        }]
      }]
    }]
  }, // ****** I(A, V, T) ******
  {
    "name": "I(A, V, T)",
    "_children": [{
      "name": "S(A Ipsi, A Contra)",
      "_children": [{
        "name": "S(V Ipsi, V Contra)",
        "_children": [{
          "name": "S(T Ipsi, T Contra)"
        }, {
          "name": "I(T Ipsi, T Contra)"
        }]
      }, {
        "name": "I(V Ipsi, V Contra)",
        "_children": [{
          "name": "S(T Ipsi, T Contra)"
        }, {
          "name": "I(T Ipsi, T Contra)"
        }]
      }]
    }, {
      "name": "I(A Ipsi, A Contra)",
      "_children": [{
        "name": "S(V Ipsi, V Contra)",
        "_children": [{
          "name": "S(T Ipsi, T Contra)"
        }, {
          "name": "I(T Ipsi, T Contra)"
        }]
      }, {
        "name": "I(V Ipsi, V Contra)",
        "_children": [{
          "name": "S(T Ipsi, T Contra)"
        }, {
          "name": "I(T Ipsi, T Contra)"
        }]
      }]
    }]
  }, // ****** one modality independent ******
  {
    "name": "I(A vs (V, T)) & S(V, T)",
    "_children": [{
      "name": "S(A Ipsi, A Contra)",
      "_children": [{
        "name": "S(V Ipsi, V Contra)",
        "_children": [{
          "name": "S(T Ipsi, T Contra)"
        }]
      }, {
        "name": "I(V Ipsi, V Contra)",
        "_children": [{
          "name": "I(T Ipsi, T Contra)"
        }]
      }]
    }, {
      "name": "I(A Ipsi, A Contra)",
      "_children": [{
        "name": "S(V Ipsi, V Contra)",
        "_children": [{
          "name": "S(T Ipsi, T Contra)"
        }]
      }, {
        "name": "I(V Ipsi, V Contra)",
        "_children": [{
          "name": "I(T Ipsi, T Contra)"
        }]
      }]
    }]
  }, {
    "name": "I(V vs (A, T)) & S(A, T)",
    "_children": [{
      "name": "S(V Ipsi, V Contra)",
      "_children": [{
        "name": "S(A Ipsi, A Contra)",
        "_children": [{
          "name": "S(T Ipsi, T Contra)"
        }]
      }, {
        "name": "I(A Ipsi, A Contra)",
        "_children": [{
          "name": "I(T Ipsi, T Contra)"
        }]
      }]
    }, {
      "name": "I(V Ipsi, V Contra)",
      "_children": [{
        "name": "S(A Ipsi, A Contra)",
        "_children": [{
          "name": "S(T Ipsi, T Contra)"
        }]
      }, {
        "name": "I(A Ipsi, A Contra)",
        "_children": [{
          "name": "I(T Ipsi, T Contra)"
        }]
      }]
    }]
  }, {
    "name": "I(T vs (A, V)) & S(A, V)",
    "_children": [{
      "name": "S(T Ipsi, T Contra)",
      "_children": [{
        "name": "S(A Ipsi, A Contra)",
        "_children": [{
          "name": "S(V Ipsi, V Contra)"
        }]
      }, {
        "name": "I(A Ipsi, A Contra)",
        "_children": [{
          "name": "I(V Ipsi, V Contra)"
        }]
      }]
    }, {
      "name": "I(T Ipsi, T Contra)",
      "_children": [{
        "name": "S(A Ipsi, A Contra)",
        "_children": [{
          "name": "S(V Ipsi, V Contra)"
        }]
      }, {
        "name": "I(A Ipsi, A Contra)",
        "_children": [{
          "name": "I(V Ipsi, V Contra)"
        }]
      }]
    }]
  }]
}];