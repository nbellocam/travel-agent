from google.adk.agents import Agent

root_agent = Agent(
    model='gemini-3.5-flash',
    name='hotel_agent',
    description='A helpful assistant that answers questions about hotels in South America.',
    instruction=(
        'Answer user questions about hotels in Argentina, Uruguay and Chile to the '
        'best of your knowledge. Do not answer questions outside of this.'
    ),
)
