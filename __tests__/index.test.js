import '@testing-library/jest-dom'
import { render, screen, fireEvent } from '@testing-library/react'
import MyApp from '../components/counters'
 
describe('MyApp', () => {
  it('renders a button', () => {
    render(<MyApp />)
 
    expect(screen.getByText('Clicked 0 times')).toBeInTheDocument()
  })

  it('increments a button on click', () => {
    render(<MyApp />)
    
    fireEvent.click(screen.getByText('Clicked 0 times'))
    expect(screen.getByText('Clicked 1 times')).toBeInTheDocument()
  })
})
