export function createInlineEditController(Controller) {
  return class InlineEditController extends Controller {
    static targets = ["display", "form", "input", "error"];
    static values = {
      url: String,
      field: String,
      originalValue: String,
      fieldType: { type: String, default: "input" },
      collection: { type: Array, default: [] },
      modelName: { type: String, default: "record" },
    };

    showForm(event) {
      event.preventDefault();

      if (!this.hasFormTarget || !this.hasInputTarget) {
        console.error("Missing form or input targets");
        return;
      }

      this.displayTarget.style.display = "none";
      this.formTarget.style.display = "block";
      this.inputTarget.focus();
    }

    hideForm() {
      if (!this.hasFormTarget) {
        return;
      }
      this.formTarget.style.display = "none";
      this.displayTarget.style.display = "";
    }

    handleKeydown(event) {
      if (event.key === "Enter") {
        event.preventDefault();
        this.submitFormAndHide();
      } else if (event.key === "Escape") {
        this.hideForm();
      }
    }

    showError(error) {
      if (this.hasErrorTarget) {
        let errorText = "";

        try {
          if (error instanceof Error) {
            errorText = error.message;
          } else if (typeof error === "object" && error !== null) {
            if (error.errors && typeof error.errors === "object") {
              const errorMessages = [];
              for (const [field, messages] of Object.entries(error.errors)) {
                if (Array.isArray(messages)) {
                  messages.forEach((message) => {
                    errorMessages.push(`${field} ${message}`);
                  });
                } else {
                  errorMessages.push(`${field} ${messages}`);
                }
              }
              errorText = errorMessages.join("\n");
            } else {
              errorText = JSON.stringify(error, null, 2);
            }
          } else {
            errorText = String(error);
          }
        } catch (e) {
          errorText = String(error);
        }

        this.errorTarget.textContent = errorText;
        this.errorTarget.style.display = "block";
        this.errorTarget.style.color = "red";
        this.errorTarget.style.whiteSpace = "pre-line";
      }
    }

    hideError() {
      if (this.hasErrorTarget) {
        this.errorTarget.textContent = "";
        this.errorTarget.style.display = "none";
      }
    }

    async submitFormAndHide() {
      if (this.hasDisplayTarget) {
        let value;
        switch (this.fieldTypeValue) {
          case "checkbox":
            value = this.inputTarget.checked ? "1" : "0";
            this.displayTarget.textContent = this.inputTarget.checked
              ? "Да"
              : "Нет";
            break;
          case "select":
            const selectedOption =
              this.inputTarget.options[this.inputTarget.selectedIndex];
            // в Safary из options.value приходят только текст а не HTML поэтому используем data-html атрибут
            const selectedHTML = selectedOption.getAttribute("data-html");
            this.displayTarget.innerHTML = selectedHTML;
            break;
          default:
            value = this.inputTarget.value;
            this.displayTarget.textContent = value || "-";
            break;
        }
      }

      const success = await this.submitForm();
      if (success) {
        this.hideForm();
      }
    }

    async submitForm() {
      this.hideError();

      let value;
      switch (this.fieldTypeValue) {
        case "checkbox":
          value = this.inputTarget.checked ? "1" : "0";
          break;
        default:
          value = this.inputTarget.value;
          break;
      }

      // Если значение не изменилось, не отправляем запрос
      // Но пустые значения всегда отправляем, так как они могут быть валидными
      // Специальная обработка для Safari - гарантируем, что пустые значения будут отправлены
      const isEmpty = value === "" || value === null || value === undefined;
      const valueUnchanged = value === this.originalValueValue;

      if (valueUnchanged && !isEmpty) {
        this.hideForm();
        return true;
      }

      try {
        // Используем имя модели из data-атрибута
        const modelName = this.modelNameValue || "record";
        const requestBody = {};
        requestBody[modelName] = {
          [this.fieldValue]: value,
        };

        const response = await fetch(this.urlValue, {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
            "X-CSRF-Token":
              document.querySelector('meta[name="csrf-token"]')?.content || "",
          },
          body: JSON.stringify(requestBody),
        });

        if (response.ok || response.status === 302) {
          this.originalValueValue = value;
        } else {
          const errorText = await response.text();
          let errorData;
          try {
            errorData = JSON.parse(errorText);
          } catch (e) {
            errorData = errorText;
          }
          throw errorData;
        }

        return true;
      } catch (error) {
        console.error("Error submitting form:", error);
        this.showError(error);
        return false;
      }
    }
  };
}
