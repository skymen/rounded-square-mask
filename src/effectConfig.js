// WARNING: DO NOT EDIT THIS FILE, IT IS AUTOGENERATED
module.exports = {
  addonType: "effect",
  id: "skymen_RoundedSquareMask",
  name: "Rounded Square Mask",
  version: "1.1.0.0",
  category: "blend",
  // "distortion",
  // "normal-mapping",
  // "tiling",
  // "other",
  // "color",
  author: "skymen",
  website: "https://www.construct.net",
  documentation: "https://www.construct.net",
  description: "Rounded Square Mask",
  supportedRenderers: ["webgl", "webgl2", "webgpu"],
  blendsBackground: false,
  usesDepth: false,
  crossSampling: false,
  preservesOpaqueness: false,
  animated: false,
  mustPredraw: true,
  extendBox: {
    horizontal: 0,
    vertical: 0,
  },
  isDeprecated: false,
  parameters: [
    /*
    {
      type:
        "float"
        "percent"
        "color"
      ,
      id: "property_id",
      value: 0,
      uniform: "uPropertyId",
      // precision: "lowp" // defaults to lowp if omitted
      interpolatable: true,
      name: "Property Name",
      desc: "Property Description",
    }
    */
    {
      type: "float",
      id: "angle",
      value: 0,
      uniform: "angle",
      // precision: "lowp" // defaults to lowp if omitted
      interpolatable: true,
      name: "Angle",
      desc: "Angle of the Square",
    },
    {
      type: "float",
      id: "radius",
      value: 50,
      uniform: "radius",
      // precision: "lowp" // defaults to lowp if omitted
      interpolatable: true,
      name: "Radius",
      desc: "Radius of the Square",
    },
    {
      type: "float",
      id: "width",
      value: 100,
      uniform: "width",
      // precision: "lowp" // defaults to lowp if omitted
      interpolatable: true,
      name: "Width",
      desc: "Width of the Square",
    },
    {
      type: "float",
      id: "height",
      value: 100,
      uniform: "height",
      // precision: "lowp" // defaults to lowp if omitted
      interpolatable: true,
      name: "Height",
      desc: "Height of the Square",
    },
    {
      type: "float",
      id: "radiusTL",
      value: 0,
      uniform: "radiusTL",
      // precision: "lowp" // defaults to lowp if omitted
      interpolatable: true,
      name: "Top Left Radius",
      desc: "If less or equal to 0, it will use the radius value",
    },
    {
      type: "float",
      id: "radiusTR",
      value: 0,
      uniform: "radiusTR",
      // precision: "lowp" // defaults to lowp if omitted
      interpolatable: true,
      name: "Top Right Radius",
      desc: "If less or equal to 0, it will use the radius value",
    },
    {
      type: "float",
      id: "radiusBL",
      value: 0,
      uniform: "radiusBL",
      // precision: "lowp" // defaults to lowp if omitted
      interpolatable: true,
      name: "Bottom Left Radius",
      desc: "If less or equal to 0, it will use the radius value",
    },
    {
      type: "float",
      id: "radiusBR",
      value: 0,
      uniform: "radiusBR",
      // precision: "lowp" // defaults to lowp if omitted
      interpolatable: true,
      name: "Bottom Right Radius",
      desc: "If less or equal to 0, it will use the radius value",
    },
  ],
};
