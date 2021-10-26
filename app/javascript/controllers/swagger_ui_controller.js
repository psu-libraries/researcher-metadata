import { Controller } from '@hotwired/stimulus';
import { SwaggerUIBundle, SwaggerUIStandalonePreset } from 'swagger-ui-dist';

export default class extends Controller {
  connect () {
    const config = {
      dom_id: `#${this.element.id}`,
      layout: 'StandaloneLayout',
      presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
      urls: [
        {
          url: '/api_docs/swagger_docs/v1/swagger.json',
          name: 'API V1 Docs'
        }
      ]
    };

    SwaggerUIBundle(config);
  }
}
