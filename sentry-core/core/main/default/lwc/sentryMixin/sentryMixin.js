function assertIsLightningElementSubclass(Base) {
  const baseProto = Base.prototype;

  if (typeof baseProto.dispatchEvent !== "function") {
    console.log("Base is not an Element type");

    // throw new TypeError(`${Base} must be an Element type`);
  }
}

const SentryBoundaryMixin = (Base) => {
  assertIsLightningElementSubclass(Base);
  return class extends Base {
    // errorCallback(error, stack){
    //     console.error(error);
    //     console.log(stack);
    // }
  };
};

export { SentryBoundaryMixin };
