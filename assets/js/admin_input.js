export const sendDebugAction = (type) => {
  const message = { type: type };
  document.channel.push("admin_input", message, 10000);
};
