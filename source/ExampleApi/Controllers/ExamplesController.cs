using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;

namespace example_api.Controllers
{
    [Route("v1/[controller]")]
    [ApiController]
    public class ExamplesController : ControllerBase
    {
        [HttpGet]
        public ActionResult<IEnumerable<string>> Get()
        {
            return Ok(new [] { 
                new {id="1"}, 
                new {id="2"} 
                });
        }

        [HttpGet("{id}")]
        public IActionResult Get(string id)
        {
            if(id == "non-existing")
                return NotFound();
            return Ok(new {id=id});
        }
        
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }

        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}