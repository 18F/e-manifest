var assert = chai.assert;

describe("hello", function() {

  it("world", function() {
    assert.equal(4, 4);
  });
  
  it("failure!", function() {
    assert.equal(2, 4);
  });
  
});

