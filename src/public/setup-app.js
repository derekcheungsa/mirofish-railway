// MiroFish Setup Wizard JavaScript

document.addEventListener("DOMContentLoaded", async () => {
  const statusPanel = document.getElementById("status-panel");
  const configPanel = document.getElementById("config-panel");
  const successPanel = document.getElementById("success-panel");
  const statusContent = document.getElementById("status-content");
  const configForm = document.getElementById("config-form");
  const errorMessage = document.getElementById("error-message");
  const submitBtn = document.getElementById("submit-btn");
  const resetBtn = document.getElementById("reset-btn");
  const providerSelect = document.getElementById("provider");
  const customUrlGroup = document.getElementById("custom-url-group");
  const llmBaseUrlInput = document.getElementById("llm-base-url");
  const llmApiKeyInput = document.getElementById("llm-api-key");
  const llmModelSelect = document.getElementById("llm-model");
  const appUrl = document.getElementById("app-url");

  // Track which button text/spinner to toggle
  const btnText = submitBtn.querySelector(".btn-text");
  const btnSpinner = submitBtn.querySelector(".spinner");

  // Show/hide custom URL based on provider selection
  providerSelect.addEventListener("change", () => {
    const isCustom = providerSelect.value === "custom";
    customUrlGroup.classList.toggle("hidden", !isCustom);
  });

  // Fetch current status
  async function fetchStatus() {
    try {
      const res = await fetch("/setup/api/status");
      const data = await res.json();
      return data;
    } catch (err) {
      return { configured: false, error: err.message };
    }
  }

  // Render status view
  function renderStatus(status) {
    if (status.configured) {
      statusPanel.classList.add("hidden");
      configPanel.classList.add("hidden");
      successPanel.classList.remove("hidden");

      if (status.publicUrl) {
        appUrl.href = status.publicUrl;
      } else {
        appUrl.href = "/";
      }
    } else {
      statusPanel.classList.add("hidden");
      configPanel.classList.remove("hidden");
      successPanel.classList.add("hidden");
    }
  }

  // Load status on page load
  const status = await fetchStatus();
  renderStatus(status);

  // Handle form submission
  configForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    errorMessage.classList.add("hidden");

    // Show loading state
    btnText.textContent = "Saving...";
    btnSpinner.classList.remove("hidden");
    submitBtn.disabled = true;

    try {
      const provider = providerSelect.value;
      const llmApiKey = llmApiKeyInput.value;
      const llmModelName = llmModelSelect.value;
      const llmBaseUrl = provider === "custom"
        ? llmBaseUrlInput.value
        : provider === "openrouter"
          ? "https://openrouter.ai/api/v1"
          : provider === "openai"
            ? "https://api.openai.com/v1"
            : provider === "anthropic"
              ? "https://api.anthropic.com"
              : llmBaseUrlInput.value;

      const zepApiKey = document.getElementById("zep-api-key").value;

      const res = await fetch("/setup/api/configure", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          llmApiKey,
          llmBaseUrl,
          llmModelName,
          zepApiKey,
        }),
      });

      const result = await res.json();

      if (!result.ok) {
        throw new Error(result.error || "Configuration failed");
      }

      // Show success - reload to see the app
      statusPanel.classList.add("hidden");
      configPanel.classList.add("hidden");
      successPanel.classList.remove("hidden");

    } catch (err) {
      errorMessage.textContent = err.message;
      errorMessage.classList.remove("hidden");
    } finally {
      btnText.textContent = "Save Configuration";
      btnSpinner.classList.add("hidden");
      submitBtn.disabled = false;
    }
  });

  // Handle reset
  resetBtn.addEventListener("click", async () => {
    if (!confirm("Reset configuration? This will clear your API keys.")) {
      return;
    }

    resetBtn.disabled = true;
    resetBtn.textContent = "Resetting...";

    try {
      await fetch("/setup/api/reset", { method: "POST" });
      window.location.reload();
    } catch (err) {
      alert("Reset failed: " + err.message);
      resetBtn.disabled = false;
      resetBtn.textContent = "Reset Configuration";
    }
  });
});
