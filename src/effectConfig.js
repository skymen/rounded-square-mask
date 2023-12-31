// WARNING: DO NOT EDIT THIS FILE, IT IS AUTOGENERATED
module.exports = {
  addonType: "effect",
  id: "skymen_RoundedSquareMask",
  name: "Rounded Square Mask",
  version: "1.0.0.2",
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
  ],
};
