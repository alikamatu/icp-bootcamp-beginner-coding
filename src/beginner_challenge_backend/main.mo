import Result "mo:base/Result";
import Text "mo:base/Text";
import Vector "mo:vector";
import Nat "mo:base/Nat";
import Map "mo:map/Map";
import Debug "mo:base/Debug";
import { phash; nhash } "mo:map/Map";

actor {
    stable var nextId : Nat = 0;
    stable var userIdMap : Map.Map<Principal, Nat> = Map.new<Principal, Nat>();
    stable var userProfileMap : Map.Map<Nat, Text> = Map.new<Nat, Text>();
    stable var userResultsMap : Map.Map<Nat, Vector.Vector<Text>> = Map.new<Nat, Vector.Vector<Text>>();

    public query ({ caller }) func getUserProfile() : async Result.Result<{ id : Nat; name : Text }, Text> {
        let userId = switch (Map.get(userIdMap, phash, caller)) {
            case (?found) found;
            case (_) return #err("User not found");
        };

        let name = switch (Map.get(userProfileMap, nhash, userId)) {
            case (?found) found;
            case (_) return #err("User name not found");
        };

        return #ok({ id = 123; name = "test" });
    };

    public shared ({ caller }) func setUserProfile(name : Text) : async Result.Result<{ id : Nat; name : Text }, Text> {
        Debug.print(debug_show caller);
        //guardian clause to check if the user already exists
        switch (Map.get(userIdMap, phash, caller)) {
            case (?caller) {
                // Map.set[userIdMap phash, caller, idFound];
                // Map.set[userProfileMap nhash, nextId, name];
                // idRecorded := idFound;
            };
            case (_) {
                Map.set(userIdMap, phash, caller, nextId);
                Map.set(userProfileMap, nhash, nextId, name);
                nextId += 1;

                // return #err("This user already has an ID:" #Nat.toText(idFound));
            };
        };

        // Search for existing user ID
        let foundId = switch (Map.get(userIdMap, phash, caller)) {
            case (?id) id;
            case (_) { return #err("User ID not found") };
        };

        // Set the existing user profile name
        Map.set(userProfileMap, nhash, foundId, name);

        return #ok({ id = foundId; name = name });
    };

    public shared ({ caller }) func addUserResult(result : Text) : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        let userId = switch (Map.get(userIdMap, phash, caller)) {
            case (?caller) caller;
            case (_) { return #err("User not found!") };
        };
        let userResult = switch (Map.get(userResultsMap, nhash, userId)) {
            case (?result) result;
            case (_) { Vector.new<Text>() };
        };
        Vector.add(userResult, result);
        Map.set(userResultsMap, nhash, userId, userResult);

        return #ok({ id = userId; results = Vector.toArray(userResult) });
    };

    public query ({ caller }) func getUserResults() : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        return #ok({ id = 123; results = ["fake result"] });
    };
};
