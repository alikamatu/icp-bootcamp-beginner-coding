import { useState } from "react";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import {
  canisterId,
  createActor,
} from "declarations/beginner_challenge_backend";

function IdentityLogin(props) {
  const [isLoading, setIsLoading] = useState(false);

  async function handleLogin() {
    setIsLoading(true);
    try {
      const authClient = await AuthClient.create();
      const identity_url =
        process.env.DFX_NETWORK === "local"
          ? `http://${process.env.CANISTER_ID_INTERNET_IDENTITY}.localhost:4943`
          : "https://identity.ic0.app";

      await new Promise((resolve) =>
        authClient.login({
          identityProvider: identity_url,
          onSuccess: resolve,
        }),
      );

      const identity = authClient.getIdentity();
      const agent = await HttpAgent.create({ identity });
      if (process.env.DFX_NETWORK === "local") {
        await agent.fetchRootKey();
      }

      const backendActor = createActor(canisterId, { agent });
      props.setBackendActor(backendActor);
    } catch (error) {
      console.error("Login failed:", error);
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <button 
      className="auth-button" 
      onClick={handleLogin} 
      disabled={isLoading}
    >
      {isLoading ? (
        <span className="loading">Connecting...</span>
      ) : (
        <>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style={{verticalAlign: 'middle', marginRight: '8px'}}>
            <path d="M12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M12 8V16" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M8 12H16" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
          Login with Internet Identity
        </>
      )}
    </button>
  );
}

export default IdentityLogin;