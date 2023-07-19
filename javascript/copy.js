const copyText = (text) => {
    const input = document.createElement("input");
    input.setAttribute("value", text);
    document.body.appendChild(input);
    input.select();
    const result = document.execCommand("copy");
    document.body.removeChild(input);

    return result;
};

window.addEventListener("message", (e) => {
    const event = e.data.event;
    const text = e.data.text;

    if (event == "copy") {
        copyText(text);
    }
});
