# Potatoes Web App

This is a web application for the Potatoes project. It is built on with the [@mysten/create-dapp](https://npmjs.com/package/@mysten/create-dapp) package.

## Structure

Base application manages routing and authentication. Applications are integraded as sub-applications placed in the [apps](./src/apps/) directory.

## Running the application

To run the application locally, use `pnpm dev`.

## Adding a new application

To add a new application, follow these steps:

1. Create a new directory in the [apps](./src/apps/) directory.
2. Update the [App.tsx](./src/App.tsx) file to include the link in the sidebar and the route.
3. Add all necessary variables into the [constants.tsx](./src/constants.tsx) and [networkConfig.tsx](./src/networkConfig.tsx) files.
