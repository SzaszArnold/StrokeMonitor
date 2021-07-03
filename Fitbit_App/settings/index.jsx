/*Based on the documentation at the link: https://dev.fitbit.com/build/reference/settings-api/#general-tips*/
function authFlow(props) {
    return (
        <Page>
            <Section
                title={<Text bold align="center">Fitbit Account</Text>}>
                <Oauth
                    settingsKey="oauth"
                    title="Login"
                    label="Fitbit"
                    status="Login"
                    authorizeUrl="https://www.fitbit.com/oauth2/authorize"
                    requestTokenUrl="https://api.fitbit.com/oauth2/token"
                    clientId="23B7TN"
                    clientSecret="90c60dbf288d3194520ee04cac4f7bfb"
                    scope="profile"
                />
            </Section>
        </Page>
    );
}
registerSettingsPage(authFlow);
