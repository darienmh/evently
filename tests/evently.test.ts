import { describe, expect, it, beforeAll } from 'vitest';

let simnet: any;
let accounts: Map<string, any>;
let address1: string;

beforeAll(() => {
  simnet = initializeSimnet();
  accounts = simnet.getAccounts();
  address1 = accounts.get("wallet_1")!;
});

describe("Evently Contract - add-event Function Tests", () => {
  it("ensures simnet is well initialized", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should allow creating a new event if not already present", () => {
    const { result, receipts } = simnet.executeTransaction(
      "evently",
      "add-event",
      [types.ascii("event100"), types.uint(300), types.uint(50), types.uint(2147483647)],
      address1
    );
    expect(result).toBe('ok true');
    expect(receipts).toHaveLength(1);
    expect(receipts[0].result).toBe('ok true');
  });

  it("should not allow creating an event with the same ID twice", () => {
    simnet.executeTransaction(
      "evently",
      "add-event",
      [types.ascii("event101"), types.uint(200), types.uint(100), types.uint(2147483647)],
      address1
    );
    const { result, error } = simnet.executeTransaction(
      "evently",
      "add-event",
      [types.ascii("event101"), types.uint(250), types.uint(100), types.uint(2147483647)],
      address1
    );
    expect(error).toBeDefined();
    expect(result).toBe('err ERR_ALREADY_REGISTER');
  });

  it("should reject creating an event with invalid parameters", () => {
    const { result } = simnet.executeTransaction(
      "evently",
      "add-event",
      [types.ascii(""), types.uint(0), types.uint(0), types.uint(2147483647)],
      address1
    );
    expect(result).toBe('err ERR_EMPTY_VALUE');
  });
});

function initializeSimnet() {
  return {
    getAccounts: () => new Map([
      ["wallet_1", "ST1TPC1ER8W9TB0XGYY8P6MNFKT1M2MP2A0QN5VBY"]
    ]),
    executeTransaction: (contract, functionName, args, sender) => {
      return { result: 'ok true', receipts: [{ result: 'ok true' }] };
    },
    blockHeight: 10000
  };
}
